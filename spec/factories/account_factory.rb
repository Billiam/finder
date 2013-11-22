require 'factory_girl'

FactoryGirl.define do
  factory :account do
    pass = SecureRandom.urlsafe_base64

    name "John"
    surname "Doe"
    sequence(:email) { |n| "person#{n}@example.com" }
    password pass
    password_confirmation pass
    role 'moderator'
  end

  factory :admin do
    role 'admin'
  end
end