require 'spec_helper'
require 'acceptance/acceptance_helper'

describe "an instance generated by a factory that inherits from another factory" do
  before do
    define_model("User", :name => :string, :admin => :boolean, :email => :string)

    FactoryGirl.define do
      factory :user do
        name  "John"
        email { "#{name.downcase}@example.com" }

        factory :admin do
          name "admin"
          admin true
        end

        factory :guest do
          email { "#{name}-guest@example.com" }
        end
      end
    end
  end

  describe "the parent class" do
    subject     { FactoryGirl.create(:user) }
    it          { should_not be_admin }
    its(:email) { should == "john@example.com" }
  end

  describe "the child class redefining parent's static method used by a dynamic method" do
    subject     { FactoryGirl.create(:admin) }
    it          { should be_kind_of(User) }
    it          { should be_admin }
    its(:name)  { should == "admin" }
    its(:email) { should == "admin@example.com" }
  end

  describe "the child class redefining parent's dynamic method" do
    subject     { FactoryGirl.create(:guest) }
    it          { should_not be_admin }
    its(:name)  { should == "John" }
    its(:email) { should eql "John-guest@example.com" }
  end
end

