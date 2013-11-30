require 'spec_helper'

describe GongBot::Parser::Remove do
  describe '.from_messages' do
    let(:data) do
      [{
           author: 'user',
           arbitrary_data: 'foo',
       }]
    end

    let(:parser) do
      GongBot::Parser::Remove
    end

    let(:results) do
      parser.from_messages data
    end

    it "returns a list of usernames for removal" do
      expect(results).to eq(['user'])
    end
  end
end