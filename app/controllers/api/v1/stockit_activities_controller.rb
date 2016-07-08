module Api::V1
  class StockitActivitiesController < Api::V1::ApiController

    skip_before_action :validate_token, only: [:create]
    load_and_authorize_resource :stockit_activity, parent: false

    resource_description do
      formats ['json']
      error 401, "Unauthorized"
      error 404, "Not Found"
      error 422, "Validation Error"
      error 500, "Internal Server Error"
    end

    def_param_group :stockit_activity do
      param :stockit_activity, Hash, required: true do
        param :name, String, desc: "Name of Activity"
        param :stockit_id, String, desc: "stockit activity record id"
      end
    end

    api :POST, "/v1/stockit_acitivites", "Create or Update a stockit_activity"
    param_group :stockit_activity
    def create
      if stockit_activity_record.save
        render json: {}, status: 201
      else
        render json: @stockit_activity.errors.to_json, status: 422
      end
    end

    private

    def stockit_activity_record
      @stockit_activity = StockitActivity.where(stockit_id: stockit_activity_params[:stockit_id]).first_or_initialize
      @stockit_activity.assign_attributes(stockit_activity_params)
      @stockit_activity
    end

    def stockit_activity_params
      params.require(:stockit_activity).permit(:stockit_id, :name)
    end
  end
end