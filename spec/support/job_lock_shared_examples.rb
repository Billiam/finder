shared_examples 'Job Lock' do
  it { should be_timestamped_document }
  it { should have_fields(:expire, :type) }

  it { should have_index_for(expire: 1).with_options(expireAfterSeconds: 0) }
  it { should have_index_for(type: 1).with_options(unique: true) }

  describe 'before_create' do
    it 'runs callbacks' do
      job = build_stubbed(described_class)
      expect(job).to receive(:set_expire)
      expect(job).to receive(:set_type)
      job.run_callbacks(:create) { false }
    end
  end

  describe '#set_expire' do
    before(:each) { Time.stub(:now) { stubbed_time } }
    let(:stubbed_time) { Time.new(2013,11,29,1,0) }
    let(:job) { build_stubbed(described_class) }

    it 'sets the expiration time' do
      expect(job).to receive(:expire=).with(stubbed_time + described_class.expiration)
      job.send(:set_expire)
    end
  end

  describe '#set_type' do
    let(:job) { build_stubbed(described_class) }

    it 'sets the job type' do
      expect(job).to receive(:type=).with(described_class.name)
      job.send(:set_type)
    end
  end
end