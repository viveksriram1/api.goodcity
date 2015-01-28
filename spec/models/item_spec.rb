require 'rails_helper'

RSpec.describe Item, type: :model do

  it_behaves_like 'paranoid'

  describe 'Associations' do
    it { should belong_to :offer }
    it { should belong_to :item_type }
    it { should belong_to :rejection_reason }
    it { should belong_to :donor_condition }
    it { should have_many :messages }
    it { should have_many :images }
    it { should have_many :packages }
  end

  describe 'Database Columns' do
    it { should have_db_column(:donor_description).of_type(:text) }
    it { should have_db_column(:state).of_type(:string) }
    it { should have_db_column(:offer_id).of_type(:integer) }
    it { should have_db_column(:item_type_id).of_type(:integer) }
    it { should have_db_column(:rejection_reason_id).of_type(:integer) }
    it { should have_db_column(:reject_reason).of_type(:string) }
    it { should have_db_column(:rejection_comments).of_type(:string) }
    it { should have_db_column(:saleable).of_type(:boolean) }
  end

  describe "validations" do
    it { should validate_presence_of(:donor_condition_id) }
  end

  describe 'Scope Methods' do
    let!(:item)    { create :item }
    let!(:an_item) { create :item } # this item should not be changed

    describe 'update_saleable' do
      it 'should update all items of offer' do
        expect{
          item.update_saleable
        }.to change(Item.where(saleable: true), :count).by(1)
        expect(an_item).to_not be_saleable
      end
    end
  end

  describe "Instance Methods" do
    let!(:offer) { create :offer, state: "submitted" }
    let!(:item)  { create :item, offer: offer }
    let!(:reviewer) { create :user, :reviewer }
    before { User.current_user = reviewer }

    describe "assign_reviewer" do
      it "should update all items of offer" do
        expect{
          item.accept
        }.to change(offer, :reviewed_by).to(reviewer)
        expect(offer.state).to eq("under_review")
      end
    end
  end
end
