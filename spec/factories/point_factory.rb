require 'factory_girl'

FactoryGirl.define do
  factory :point do
    sequence(:name) { |n| "redditor_#{n}" }
    location [-83.131389,37.335]
    status 'pending'
    country 'US'
    county 'Perry County'
    city 'Dwarf'
    state 'KY'
    search 'Dwarf, KY'
  end
end