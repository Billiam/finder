require 'spec_helper'

describe GongBot::Parser::Gong do
  describe '.from_messages' do
    let(:data) do
     [{
        author: 'user',
        date: Time.at(1385683200),
        arbitrary_data: 'foo',
      }]
    end

    let(:parser) do
      GongBot::Parser::Gong
    end

    let(:results) do
      parser.from_messages(data).first
    end

    it "maps message author to username" do
      expect(results).to include username: 'user'
    end

    it "includes message date" do
      expect(results).to include date: Time.at(1385683200)
    end
  end
end