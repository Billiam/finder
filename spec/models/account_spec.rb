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

  describe "password validation" do
    subject(:user) { FactoryGirl.create(:account, password: 'banana', password_confirmation: 'banana') }

    its(:crypted_password) { should_not be_empty }

    describe "#has_password?" do
      it "allows valid passwords" do
        expect(user.has_password?('banana')).to be_true
      end

      it "rejects bad passwords" do
        expect(user.has_password?('bananas')).to be_false
      end
    end
  end

  describe ".find_by_id" do
    before(:each) { FactoryGirl.create :account, :_id => 'banana' }
    subject { lambda { |id| Account.find_by_id(id) } }

    context 'with valid id' do
      it { expect(subject.call('banana')).to be_a(Account) }
    end

    context 'with invalid id' do
      it { expect(subject.call('not_banana')).to be_nil }
    end
  end

  describe ".authenticate" do
    let!(:user) { FactoryGirl.create :account, email: 'test@test.com', password: 'banana', password_confirmation: 'banana' }

    it 'rejects invalid credentials' do
      expect(Account.authenticate('best@test.com','banana')).to be_nil
    end

    it 'accepts valid credentials' do
      expect(Account.authenticate('Test@test.com','banana')).to eql(user)
    end
  end
end
