require 'spec_helper'

describe GeocodeLock, type: :model do
  it 'has a valid factory' do
    expect(build(:geocode_lock)).to be_valid
  end

  before(:each) { Time.stub(:now) { stubbed_time } }
  let(:stubbed_time) { Time.new(2013,11,29,1,0) }
  let(:job) { create(:geocode_lock) }

  it 'expires after 19 minutes' do
    expect(job.expire).to eql(Time.new(2013, 11, 29, 1, 19))
  end

  it_behaves_like 'Job Lock'
end
