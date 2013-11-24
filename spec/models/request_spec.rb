require 'spec_helper'

describe Request, type: :model do
  it 'has a valid factory' do
    build(:request).should be_valid
  end

  it { should have_fields(:name, :lname, :pm, :search) }
  it { should have_field(:status).of_type(String).with_default_value_of('new') }

  it { should validate_length_of(:name).with_minimum(3) }
  it { should validate_uniqueness_of(:lname) }
  it { should validate_presence_of(:search) }
  it { should validate_inclusion_of(:status).to_allow('new', 'processing', 'success', 'fail') }

  it { should have_index_for(status: 1, created_at: -1) }

  it { should be_timestamped_document }
  it { should be_bulk_upsertable_document }

  it_behaves_like 'batch upsertable'

  describe '.ready' do
    %w(new processing success fail).each do |status|
      let!("#{status}_request".to_sym) { create(:request, status: status) }
    end

    it "includes requests with new flag" do
      Request.ready.all.entries.should include(new_request)
    end

    %w(processing success fail).each do |status|
      it "excludes #{status} requests" do
        Request.ready.all.entries.should_not include(send("#{status}_request".to_sym))
      end
    end
  end

  describe '.by_name' do
    %w(user_1 user_2 user_3).each do |name|
      let!(name) { create :request, name: name }
    end

    def find(name)
      Request.by_name(name).all.entries
    end

    it 'finds existing request by name' do
      expect(find('UsEr_1')).to eql([user_1])
    end

    it 'finds multiple requests by name' do
      expect(find(['UsEr_1', 'user_2'])).to match_array([user_1, user_2])
    end

    it 'is empty for non-existant request' do
      expect(find('user_4')).to eql([])
    end
  end

  describe 'before_validation' do
    it 'runs callbacks' do
      request = build_stubbed(:request)
      expect(request).to receive(:set_case_insensitive)
      request.run_callbacks(:validation) { false }
    end
  end

  describe '#set_case_insensitive' do
    it 'sets a lowercased name' do
      request = build_stubbed(:request, name: 'BANANA')

      expect(request).to receive(:lname=).with('banana')

      request.send(:set_case_insensitive)
    end

    it 'does not lowercase name when name has not changed' do
      request = create(:request)
      expect(request).not_to receive(:lname=)

      request.send(:set_case_insensitive)
    end
  end
end
