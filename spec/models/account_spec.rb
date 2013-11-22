require 'spec_helper'

describe Account, type: :model do
  it 'has a valid factory' do
    FactoryGirl.build(:account).should be_valid
  end

  it { should have_fields(:name, :surname, :email, :crypted_password, :role) }

  it { should allow_mass_assignment_of(:password) }
  it { should allow_mass_assignment_of(:password_confirmation) }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:role) }

  it { should validate_length_of(:email).within(3..100) }
  it { should validate_uniqueness_of(:email).case_insensitive }

  it { should validate_format_of(:email).to_allow("test@test.com").not_to_allow("test.com") }
  it { should validate_inclusion_of(:role).to_allow("admin", "moderator") }

  context "after creation" do
    let(:user) { FactoryGirl.create(:account) }

    it "encrypts the user password" do
      expect(user.crypted_password).not_to be_empty
    end
  end
end
