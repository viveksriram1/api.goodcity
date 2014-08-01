module Api::V1
  class MessagesController < Api::V1::ApiController

    load_and_authorize_resource :message, parent: false

    def index
      @messages = @messages.find( params[:ids].split(",") ) if params[:ids].present?
      render json: @messages, each_serializer: serializer
    end

    def show
      render json: @message, serializer: serializer
    end

    private

    def serializer
      Api::V1::MessageSerializer
    end

  end
end
