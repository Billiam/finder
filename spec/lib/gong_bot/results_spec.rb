require 'spec_helper'

describe GongBot::Results do
  let(:registration) do
    double('registration_data')
  end

  let(:removal) do
    double('removal_data')
  end

  let(:gong) do
    double('gong_data')
  end

  let(:data) do
    {
      registrations: registration,
      remove: removal,
      gongs: gong,
    }
  end

  describe "#data" do
    let(:results) do
      GongBot::Results.new data
    end

    it "responds with input data" do
      expect(results.data).to be data
    end
  end

  describe "#data=" do
    let(:results) do
      results = GongBot::Results.new({original_data: true})
      results.data = data
      results
    end

    it "responds with data from setter" do
      expect(results.data).to be data
    end
  end

  context "when parsing data" do
    let(:results) do
      GongBot::Results.new data
    end

    access_methods = {
      registration: 'Register',
      gong: 'Gong',
      removal: 'Remove',
    }

    access_methods.each do |type, parser_type|
      describe "##{type}" do
        let(:parser) do
          ::GongBot::Parser.const_get(parser_type)
        end

        let(:result_type) do
          send(type)
        end

        it "fetches #{type} data from parser" do
          expect(parser).to receive(:from_messages).with(result_type)
          results.public_send(type)
        end

        context "when returning data" do
          let(:parsed_data) do
            double("#{type}_results")
          end

          before(:each) do
            parser.stub(:from_messages) { parsed_data }
          end

          it "returns parsed results" do
            expect(results.send(type)).to be parsed_data
          end

          it "memoizes #{type} lookup" do
            results.send(type)

            expect(parser).not_to receive(:from_messages)
            results.send(type)
          end
        end
      end
    end
  end
end