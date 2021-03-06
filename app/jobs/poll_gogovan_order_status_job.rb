class PollGogovanOrderStatusJob < ActiveJob::Base
  queue_as :gogovan_orders

  def perform(order_id)
    order = GogovanOrder.find_by(id: order_id)
    if order.try(:delivery)
      Rails.logger.info "Updating GGV Order #{order_id}"

      # GGV Order is not placed successfully i.r. booking_id is nil
      return remove_delivery(order_id) unless order.booking_id

      # GGV Order or its Offer is cancelled
      return unless order.need_polling?

      order_details = Gogovan.order_status(order.booking_id)
      if order_details[:error]
        notify_error(order_details, order)
      else
        update_ggv_booking(order_details, order)
      end
    else
      order.try(:destroy)
    end
  end

  def update_ggv_booking(details, order)
    order = order.assign_details(details)
    return remove_delivery(order.id) if order.cancelled?

    order.save if order.changed? # avoid un-necessary push-updates to api
    schedule_polling(order) if order.reload.need_polling?
  end

  def notify_error(details, order)
    remove_delivery(order.id) if details[:error].include?("404")
    schedule_polling(order) if details[:error].include?("503")
    raise(ValueError, details[:error])
  end

  def remove_delivery(order_id)
    GgvDeliveryCleanupJob.perform_later(order_id)
  end

  def schedule_polling(order)
    wait_time =
      if order.donor.try(:online?)
        GGV_POLL_JOB_WAIT_TIME_FOR_ONLINE_DONOR + rand(GGV_POLL_JOB_WAIT_TIME_FOR_ONLINE_DONOR)
      else
        GGV_POLL_JOB_WAIT_TIME + rand(GGV_POLL_JOB_WAIT_TIME)
      end
    self.class.set(wait: wait_time).perform_later(order.id)
  end

  class ValueError < StandardError; end

end
