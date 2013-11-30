require 'spec_helper'

describe Mapquest::Override do
  describe '.fix' do
    context 'with problematic locations' do
      {
        'Australia' => '{country: AU}',
        'Norway'    => '{country: NO}',
        'Argentina' => '{country: AR}',
      }.each do |input, expected|
        it %Q(translates "#{input}" to "#{expected}") do
          expect(Mapquest::Override.fix input).to eq(expected)
        end
      end
    end

    context 'with normal locations' do
      ['United States', 'Melborne, Australia'].each do |input|
        it %Q(does not alter "#{input}") do
          expect(Mapquest::Override.fix input).to eq(input)
        end
      end
    end
  end
end