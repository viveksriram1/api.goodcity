require "rails_helper"

describe Gogovan do

  let(:gogovan) { Gogovan.new(user, attributes) }

  let(:attributes) {
    {
      'name' => name,
      'mobile' => mobile,
      'pickupTime' => pickupTime,
      'needEnglish' => needEnglish,
      'needCarry' => needCarry,
      'needCart' => needCart,
      'districtId' => districtId,
      'vehicle' => vehicle,
      'offerId' => offer_id,
      'ggv_uuid' => "1234",
      'needOver6ft' => needOver6ft,
      'removeNet' => removeNet
    }
  }

  let(:user)        { create :user }
  let(:name)        { "John Roy" }
  let(:mobile)      { "+85210002000" }
  let(:pickupTime)  { Time.now.to_s }
  let(:needEnglish) { "true" }
  let(:needCart)    { "true" }
  let(:needCarry)   { "true" }
  let(:districtId)  { (create :district).id }
  let(:vehicle)     { "van" }
  let(:offer_id)    { create(:delivery).offer.id }
  let(:needOver6ft) { "true" }
  let(:removeNet)   { ["full", "half"].sample }

  context "initialization" do
    it "user" do
      expect(gogovan.user).to eql(user)
    end
    it "name" do
      expect(gogovan.name).to eql(name)
    end
    it "mobile" do
      expect(gogovan.mobile).to eql(mobile)
    end
    it "pickupTime" do
      expect(gogovan.time).to eql(pickupTime)
    end
    it "needEnglish" do
      expect(gogovan.need_english).to eql(needEnglish)
    end
    it "needOver6ft" do

      expect(gogovan.need_over_6ft).to eql(needOver6ft)
    end
    it "removeNet" do
      expect(gogovan.remove_net).to eql(removeNet)
    end
    it "needCarry" do
      expect(gogovan.need_carry).to eql(needCarry)
    end
    it "needCart" do
      expect(gogovan.need_cart).to eql(needCart)
    end
    it "districtId" do
      expect(gogovan.district_id).to eql(districtId)
    end
    it "vehicle" do
      expect(gogovan.vehicle).to eql(vehicle)
    end
  end

  context "confirm_order" do
    let(:order) { double }
    it do
      expect(gogovan).to receive(:order).and_return(order)
      expect(order).to receive(:book)
      gogovan.confirm_order
    end
  end

  context "get_order_price" do
    let(:order) { double }
    it do
      expect(gogovan).to receive(:order).and_return(order)
      expect(order).to receive(:price)
      gogovan.get_order_price
    end
  end

  context "order" do
    let(:order_attributes) { gogovan.send(:order_attributes) }
    it do
      expect(GoGoVanApi::Order).to receive(:new).with(nil, order_attributes)
      gogovan.send(:order)
    end
  end

  context "ggv driver notes" do
    it "sends both chinese and english notes" do
      base_link = "#{Rails.application.secrets.base_urls["app"]}/ggv_orders/#{attributes["ggv_uuid"]}"
      zh = I18n.t('gogovan.driver_note', link: "#{base_link}?ln=zh-tw", locale: "zh-tw")
      en = I18n.t('gogovan.driver_note', link: "#{base_link}?ln=en", locale: "en")
      expect(gogovan.send(:ggv_driver_notes)).to eql(zh + "\n" + en)
    end
  end
end
