require 'spec_helper'

describe GongBot::Parser::Register do
  describe '.from_messages' do
    let(:data) do
      [{
           author: 'user',
           date: Time.at(1385683200),
           message: ' this is a message ',
           arbitrary_data: 'foo',
       }]
    end

    let(:parser) do
      GongBot::Parser::Register
    end

    let(:results) { parser.from_messages(data).first }

    it 'removes whitespace from messages' do
      expect(results).to include(search: 'this is a message')
    end

    it 'maps authors to username' do
      expect(results).to include(name: 'user')
    end

    it 'sets the registration type to private message' do
      expect(results).to include(pm: true)
    end
  end
end