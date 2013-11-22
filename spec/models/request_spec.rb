require 'spec_helper'

describe Request, type: :model do
  it 'has a valid factory' do
    FactoryGirl.build(:account).should be_valid
  end

  it { should have_fields(:name, :lname, :pm, :search) }
  it { should have_field(:status).of_type(String).with_default_value_of('new') }

  it { should validate_length_of(:name).with_minimum(3) }
  it { should validate_uniqueness_of(:lname) }
  it { should validate_presence_of(:search) }
  it { should validate_inclusion_of(:status).to_allow('new', 'processing', 'success', 'fail') }

  it { should have_index_for(status: 1, created_at: -1) }

  it { should be_timestamped_document }

  describe '.ready'
  describe '.by_name'
  describe '.bulk_upsert'
  describe '#set_case_insensitive'
end
