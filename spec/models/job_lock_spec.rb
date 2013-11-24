require 'spec_helper'

describe JobLock, type: :model do
  it 'has a valid factory' do
    expect(build(:job_lock)).to be_valid
  end

  it_behaves_like 'Job Lock'
end
