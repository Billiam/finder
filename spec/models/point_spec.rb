require 'spec_helper'

describe Point, type: :model do
  it 'has a valid factory' do
    build(:point).should be_valid
  end

  it do
    should have_fields(
     :name, :lname, :location,
     :country, :county, :city, :state, :search
    )
  end

  it { should have_field(:status).of_type(String).with_default_value_of('pending') }

  context "as moderator" do
    it { should allow_mass_assignment_of(:status).as(:moderator) }
  end
  [:admin, :default].each do |role|
    context "as #{role}" do
      it { should allow_mass_assignment_of(:status).as(role) }
      it { should allow_mass_assignment_of(:name).as(role) }
      it { should allow_mass_assignment_of(:status).as(role) }
      it { should allow_mass_assignment_of(:location).as(role) }
      it { should allow_mass_assignment_of(:country).as(role) }
      it { should allow_mass_assignment_of(:county).as(role) }
      it { should allow_mass_assignment_of(:city).as(role) }
      it { should allow_mass_assignment_of(:state).as(role) }
      it { should allow_mass_assignment_of(:search).as(role) }
    end
  end

  it { should be_timestamped_document }
  it { should be_bulk_upsertable_document }
  it { should be_geospatial_document }

  it_behaves_like 'batch upsertable'

  it { should have_index_for(lname: 1).with_options(unique: true) }
  it { should have_index_for(status: 1, created_at: -1) }


  it { should validate_length_of(:name).with_minimum(3) }
  it { should validate_uniqueness_of(:lname) }
  it { should validate_inclusion_of(:status).to_allow('pending', 'approved', 'denied') }

  statuses = {
    pending: :unmoderated,
    approved: :enabled,
    denied: :disabled,
  }

  statuses.each do |status, scope|
    describe ".#{scope}" do
      statuses.keys.each do |factory_status|
        let!("#{factory_status}_point".to_sym) { create(:point, status: factory_status) }
      end

      it "includes #{status} points" do
        Point.send(scope).all.entries.should include(send("#{status}_point"))
      end

      (statuses.keys - [status]).each do |reject_status|
        it "excludes #{reject_status} points" do
          Point.send(scope).all.entries.should_not include(send("#{reject_status}_point"))
        end
      end

    end
  end

  describe '.valid_filter?' do
    statuses.values.each do |status|
      it "#{status} is true" do
        expect(Point.valid_filter? status).to be_true
      end
    end
    it "unrecognized filters are false" do
      expect(Point.valid_filter? :missing).to be_false
    end
  end

  describe ".get_filter" do
    it "is a valid symbol for found filters" do
      expect(Point.get_filter 'disabled').to eql(:disabled)
    end
    it "is enabled for unrecognized filters" do
      expect(Point.get_filter 'missing').to eql(:enabled)
    end
  end

  describe ".filter" do
    it "returns scope by filter name" do
      expect(Point).to receive(:disabled)
      Point.filter 'disabled'
    end
  end

  describe '.by_name' do
    %w(user_1 user_2 user_3).each do |name|
      let!(name) { create :point, name: name }
    end

    def find(name)
      Point.by_name(name).all.entries
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

  describe ".approve" do
    let!(:pending) { create(:point, status: 'pending') }
    let!(:denied) { create(:point, status: 'denied') }

    it "approves pending points" do
      Point.approve
      expect(pending.reload.status).to eql('approved')
    end

    it "ignores disabled points" do
      Point.approve
      expect(denied.reload.status).to eql('denied')
    end
  end

  describe ".csv_columns" do
    let(:csv_columns) { [:name, :latitude, :longitude, :city, :county, :state, :country] }
    specify { expect(Point.csv_columns).to eql(csv_columns) }
  end

  describe ".to_csv" do
    let!(:approved) do
      create :point,
         status: 'approved',
         name: 'csv_test',
         location: [1.0, -1.0],
         city: 'city',
         state: 'state',
         county: 'county',
         country: 'country'
    end
    it "converts points to CSV" do
      expect(Point.to_csv).to eql <<-CSV
name,latitude,longitude,city,county,state,country
csv_test,-1.0,1.0,city,county,state,country
      CSV
    end
  end

  describe "#active?" do
    context "approved point" do
      let(:point) { build_stubbed(:point, status: 'approved') }
      it 'is active' do
        expect(point.active?).to be_true
      end
    end

    context "disabled point" do
      let(:point) { build_stubbed(:point, status: 'denied') }
      it 'is not active' do
        expect(point.active?).to be_false
      end
    end

    context "pending point" do
      let(:point) { build_stubbed(:point, status: 'pending') }
      it 'is not active' do
        expect(point.active?).to be_false
      end
    end
  end

  describe "#disabled?" do
    context "denied point" do
      let(:point) { build_stubbed(:point, status: 'denied') }
      it 'is disabled' do
        expect(point.disabled?).to be_true
      end
    end

    context "approved point" do
      let(:point) { build_stubbed(:point, status: 'approved') }
      it 'is not disabled' do
        expect(point.disabled?).to be_false
      end
    end

    context "pending point" do
      let(:point) { build_stubbed(:point, status: 'pending') }
      it 'is not disabled' do
        expect(point.disabled?).to be_false
      end
    end
  end

  describe "#location_name" do
    context "with populated location fields" do
      let(:point) { build_stubbed(:point, city: 'a', county: 'b', state: 'c', country: 'd') }
      it "is a comma-separated location string" do
        expect(point.location_name).to eql('a, b, c, d')
      end
    end
    context "with partially populated location fields" do
      let(:point) { build_stubbed(:point, city: nil, county: 'b', state: nil, country: 'd') }
      it "is a comma-separated string of populated fields" do
        expect(point.location_name).to eql('b, d')
      end
    end
  end

  describe "#to_s" do
    let(:point) { build_stubbed(:point) }
    it "is the location name" do
      expect("#{point}").to eql(point.location_name)
    end
  end

  describe "#as_csv" do
    let(:point) { build_stubbed(:point) }
    it "matches #export_attributes" do
      expect(point.as_csv).to eql(point.export_attributes)
    end
  end

  describe "#export_attributes" do
    let(:point) do
      build_stubbed :point,
             status: 'approved',
             name: 'csv_test',
             location: [1.0, -1.0],
             city: 'city',
             state: 'state',
             county: 'county',
             country: 'country'
    end

    it "exports csv row hash" do
      expect(point.export_attributes).to eql({
          name: 'csv_test',
          city: 'city',
          county: 'county',
          state: 'state',
          country: 'country',
          latitude: -1.0,
          longitude: 1.0
      })
    end
  end

  pending describe ".cluster"


  describe 'before_validation' do
    it 'runs callbacks' do
      point = build_stubbed(:point)
      expect(point).to receive(:set_case_insensitive)
      point.run_callbacks(:validation) { false }
    end
  end

  describe '#set_case_insensitive' do
    it 'sets a lowercased name' do
      point = build_stubbed(:point, name: 'BANANA')

      expect(point).to receive(:lname=).with('banana')

      point.send(:set_case_insensitive)
    end

    it 'does not lowercase name when name has not changed' do
      point = create(:point)
      expect(point).not_to receive(:lname=)

      point.send(:set_case_insensitive)
    end
  end
end