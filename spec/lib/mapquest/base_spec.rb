require 'spec_helper'

describe Mapquest do
  describe '.default_query' do
    let(:query) do
      Mapquest.default_query
    end

    before(:each) do
      ENV.stub(:[]).with("MAPQUEST_KEY") { 'abcd' }
    end

    it 'should disable thumbnails' do
      expect(query).to include(thumbMaps: false)
    end

    it 'should only fetch one result per address' do
      expect(query).to include(maxResults: 1)
    end

    it 'should set an api key' do
      expect(query).to include(key: 'abcd')
    end
  end

  describe '.format_search' do
    examples = {
      'abc' => 'abc',
      ' abc ' => 'abc',
      'search.period' => 'searchperiod',
      ' search      spaces ' => 'search spaces',
    }
    examples.each do |input, expected|
      it %Q(filters "#{input}" to "#{expected}") do
        expect(Mapquest.format_search(input)).to eql(expected)
      end
    end
  end

  describe ".lookup" do
    describe 'data lookup' do
      let(:result) do
        Mapquest.lookup location
      end

      let(:first_result) do
        result['results'].first
      end

      let(:location_results) do
        first_result['locations']
      end

      context 'with no addresses provided' do
        let(:location) do
          []
        end

        it 'returns false' do
          expect(result).to be_false
        end

        it 'does not make a web request' do
          stub_request(:any, //).to_raise(StandardError)
          expect { result }.not_to raise_error
        end
      end

      context 'with a single address' do
        use_vcr_cassette "mapquest/single", record: :new_episodes

        let(:location) do
          'Dwarf, KY'
        end

        it 'makes a web request' do
          stub_request(:any, //).to_raise(StandardError)
          expect { result }.to raise_error
        end

        it 'returns a single location result' do
          expect(result['results'].count).to be(1)
        end

        it 'returns a single geocoded address' do
          expect(location_results.count).to be(1)
        end

        it 'returns a city-level address' do
          expect(location_results.first['geocodeQuality']).to eql('CITY')
        end

        it 'returns the correct city for the input' do
          expect(location_results.first['adminArea5']).to eql('Dwarf')
        end

        it 'returns the provided location' do
          expect(first_result['providedLocation']['location']).to eq('Dwarf, KY')
        end
      end

      context 'with multiple addresses' do
        use_vcr_cassette "mapquest/multiple", record: :new_episodes

        let(:location) do
          ['Dwarf, KY', 'Welcome, MN, US', 'Backlass, Scotland']
        end

        let(:provided_location_result) do
          result['results'].map do |r|
            r['providedLocation']['location']
          end
        end

        it 'returns multiple location results' do
          expect(result['results'].count).to be(3)
        end

        it 'returns results ordered by input addresses' do
          expect(provided_location_result).to eq(location)
        end
      end
    end

    describe 'authentication' do
      let (:location) do
        'Dwarf, KY'
      end

      let(:response) do
        Mapquest.lookup location
      end

      context 'with an invalid API Key' do
        use_vcr_cassette "mapquest/error", record: :new_episodes

        before(:each) do
          ENV.stub(:[]).with("MAPQUEST_KEY") { 'abcd' }
        end

        it 'is forbidden' do
          expect(response['info']['statuscode']).to be 403
        end
      end

      context 'with a valid API Key' do
        use_vcr_cassette "mapquest/success", record: :new_episodes

        it 'responds successfully' do
          expect(response['info']['statuscode']).to be 0
        end
      end
    end
  end

  describe '.geocode' do

    let(:result) do
      Mapquest.geocode addresses
    end

    context 'with problematic address' do
      use_vcr_cassette "mapquest/geocode_problematic", record: :new_episodes

      let(:addresses) do
        {
          user1: 'Australia',
        }
      end

      it 'filters incoming addresses' do
        expect(Mapquest).to receive(:lookup).with(['{country: AU}']).and_call_original
        result
      end

      it 'returns a valid location' do
        expect(result[:user1].formatted).to eq('AU')
      end
    end

    context 'with unlocated addresses' do
      use_vcr_cassette "mapquest/geocode_bogus", record: :new_episodes

      let(:addresses) do
        {
          user1: 'noaddress1',
          user2: 'noaddress1',
          user3: 'noaddress2',
        }
      end

      it 'returns results for provided keys' do
        expect(result).to include({
          user1: nil,
          user2: nil,
          user3: nil,
        })
      end

      it 'deduplicates data lookups' do
        expect(Mapquest).to receive(:lookup).with(['noaddress1','noaddress2']).and_call_original

        result
      end
    end

    context 'with locatable addresses' do
      use_vcr_cassette "mapquest/geocode_valid", record: :new_episodes

      let(:addresses) do
        {
          user1: 'Dwarf, KY',
          user2: 'Dwarf, KY',
          user3: 'Welcome, MN, US',
        }
      end

      it 'returns results for each address' do
        expect(result.keys).to include(:user1, :user2, :user3)
      end

      it 'geocodes all addresses' do
        expect(result.values).to be_all {|m| m.instance_of? Mapquest::Result }
      end
    end
  end

  describe '.geocode_coarse' do
    let(:result) do
      Mapquest.geocode addresses
    end

    context 'with street level addresses' do
      use_vcr_cassette "mapquest/geocode_street", record: :new_episodes

      let(:addresses) do
        {
            user1: '221 B Baker Street, London, England',
        }
      end

      it 'returns a user result' do
        expect(result[:user1]).to be_instance_of(Mapquest::Result)
      end

      it 'provides city level addresses' do
        expect(result[:user1].formatted).to eql('City of Westminster, London, England, GB')
      end
    end
  end
end