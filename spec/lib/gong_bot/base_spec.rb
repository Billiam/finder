require 'spec_helper'

describe GongBot::Base do
  let (:client) do
    nil
  end

  def pm_factory(data)
    Redd::Object::PrivateMessage.new client, data
  end

  let (:pm) do
    pm_factory({
      kind: 't4',
      data: {
        name: 'id_1234',
        author: 'user',
        body: 'content',
        created_utc: 1385683200
      }
    })
  end

  let (:comment) do
    pm_factory({
      kind: 't4',
      data: {
        name: 'id_5678',
        author: 'user',
        body: 'content',
        created_utc: 1385683200,
        was_comment: true,
      }
    })
  end

  let (:formatted_pm) do
    {
      author: 'user',
      message: 'content',
      date: Time.parse('2013-11-29'),
    }
  end

  describe ".is_remove?" do
    context 'when message contains "remove"' do
      it "returns true" do
        expect(GongBot::Base.is_remove? ' remoVe ').to be_true
      end
    end

    context 'when message contains "delete"' do
      it "returns true" do
        expect(GongBot::Base.is_remove? ' deLete ').to be_true
      end
    end

    context 'when message does not contain remove or delete' do
      it "returns false" do
        expect(GongBot::Base.is_remove? ' foo bar del ete ').to be_false
      end
    end
  end

  describe ".is_gong?" do
    context 'when message contains "gong"' do
      it "returns true" do
        expect(GongBot::Base.is_gong? ' gooooooonggggg! ').to be_true
      end
    end

    context 'when message does not contain gong' do
      it "returns false" do
        expect(GongBot::Base.is_gong? ' gone ').to be_false
      end
    end
  end

  describe ".filter_pms" do
    let(:messages) { [pm, comment] }

    it 'removes comments from list of private messages' do
      expect(GongBot::Base.filter_pms messages).to match_array([pm])
    end
  end

  describe ".format_messages" do
    it "formats an API message for consumption" do
      expect(GongBot::Base.format_message pm).to eq(formatted_pm)
    end
  end

  describe ".partition_messages" do
    let(:gong) { {message: 'gong'} }
    let(:address) { {message: 'Dwarf, KY'} }
    let(:remove) { {message: 'Remove'} }

    context 'when given a gong message' do
      it 'returns messages as gongs' do
        result = GongBot::Base.partition_messages([gong])
        expect(result[:gongs]).to eql([gong])
      end
    end

    context 'when given an address message' do
      it 'returns messages as registrations' do
        result = GongBot::Base.partition_messages([address])
        expect(result[:registrations]).to eql([address])
      end
    end

    context 'when given a removal message' do
      it 'returns messages as removals' do
        result = GongBot::Base.partition_messages([remove])
        expect(result[:remove]).to eql([remove])
      end
    end
  end

  context "when instantiated" do
    let(:bot) do
      bot = GongBot::Base.new
      bot.stub(:loggy) { log }
      bot.stub(:client) { client }
      bot
    end

    let(:results) do
      []
    end

    let(:client) do
      client = double("Redd::Client::Authenticated").as_null_object
      client.stub(:messages) { results }
      client
    end

    let(:log) do
      double("Logger").as_null_object
    end

    describe "#fetch_messages" do
      let (:inbox_messages) do
        [ pm ]
      end

      context "when fetching messages" do
        it "logs fetch messages" do
          expect(log).to receive(:info).with('Fetching info messages')
          bot.fetch_messages
        end

        it "requests messages from client" do
          expect(client).to receive(:messages)
          bot.fetch_messages
        end

        it "marks inbox as read" do
          expect(client).to receive(:messages).with('unread', true, anything)
          bot.fetch_messages
        end

        it "requests batches of 25 messages" do
          expect(client).to receive(:messages).with(anything, anything, hash_including(limit: 25))
          bot.fetch_messages
        end
      end

      context 'when connecting successfully' do
        let(:results) do
          inbox_messages
        end

        it "returns inbox messages" do
          expect(bot.fetch_messages).to eq(inbox_messages)
        end

        it "marks messages as read" do
          expect(client).to receive(:mark_many_read).with(inbox_messages)
          bot.fetch_messages
        end

        it "does not trigger warnings" do
          expect(log).not_to receive(:warn)
          bot.fetch_messages
        end
      end

      context 'when unable to connect' do
        let(:results) do
          nil
        end

        it "warns on failure" do
          expect(log).to receive(:warn) do |message|
            expect(message).to include('Unable to fetch messages')
          end
          bot.fetch_messages
        end

        it "returns empty messages" do
          expect(bot.fetch_messages).to eql([])
        end
      end
    end

    describe '#read' do
      let(:message_data) do
        [
          {
          kind: 't4',
            data: {
              body: 'Test, US',
              was_comment: false,
              author: 'user1',
              kind: 't4',
              name: 'id_abcd',
            }
          }
        ]
      end

      let(:messages) do
        message_data.map { |d| pm_factory(d) }
      end

      it 'marks client messages as read' do
        expect(client).to receive(:mark_many_read).with(messages)
        bot.read messages
      end
    end

    describe '#inbox_requests' do
      let(:bot) do
        bot = super()
        bot.stub(:fetch_messages) { [pm] }
        bot
      end

      it 'formats inbox messages' do
        expect(bot.inbox_requests).to include(registrations: [formatted_pm])
      end

      it 'returns partitioned messages' do
        expect(bot.inbox_requests.keys).to include(:registrations, :gongs, :remove)
      end
    end

    describe '#run' do
      let(:bot) do
        bot = super()
        bot.stub(:inbox_requests) { double('inbox_result').as_null_object }
        bot
      end

      let(:result_instance) do
        double('Gongbot::Results').as_null_object
      end

      before(:each) do
        GongBot::Results.stub(:new) { result_instance }
      end

      it 'logs startup messages' do
        expect(log).to receive(:debug).with('Starting gong bot')
        bot.run
      end

      it 'logs completion messages' do
        expect(log).to receive(:debug).with('Bot completed')
        bot.run
      end

      it 'returns parsed results' do
        expect(bot.run).to be(result_instance)
      end
    end

    describe '#client' do
      before(:each) do
        stub_const 'Configuration::BOT_USERNAME', 'username'
        stub_const 'Configuration::BOT_PASSWORD', 'password'
        stub_const 'Configuration::BOT_USERAGENT', 'useragent'

        bot.unstub(:client)
        client_class.stub(:new) { client }
      end

      let(:client_class) do
        ::Redd::Client::Authenticated
      end

      context 'when first called' do
        it 'sets the client username' do
          expect(client_class).to receive(:new_from_credentials).with('username', anything, anything)
          bot.client
        end

        it 'sets the client password' do
          expect(client_class).to receive(:new_from_credentials).with(anything, 'password', anything)
          bot.client
        end

        it 'sets the user agent' do
          expect(client_class).to receive(:new_from_credentials).with(anything, anything, hash_including(user_agent: 'useragent'))
          bot.client
        end
      end

      context 'when called a second time' do
        before(:each) do
          client_class.stub(:new_from_credentials).and_return(double("client"))
        end

        it 'memoizes the generated client' do
          expect(client_class).to receive(:new_from_credentials).once

          bot.client
          bot.client
        end
      end
    end
  end
end