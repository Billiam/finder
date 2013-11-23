require 'factory_girl'

FactoryGirl.define do
  factory :request do
    sequence(:name) { |n| "redditor_#{n}" }
    pm true
    search 'Dwarf, KY'
    status 'new'
  end
end