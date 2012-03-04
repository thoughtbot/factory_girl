require "spec_helper"

describe "an instance generated by a factory with multiple traits" do
  before do
    define_model("User",
                 :name          => :string,
                 :admin         => :boolean,
                 :gender        => :string,
                 :email         => :string,
                 :date_of_birth => :date,
                 :great         => :string)

    FactoryGirl.define do
      factory :user_without_admin_scoping, :class => User do
        admin_trait
      end

      factory :user do
        name "John"

        trait :great do
          great "GREAT!!!"
        end

        trait :admin do
          admin true
        end

        trait :admin_trait do
          admin true
        end

        trait :male do
          name   "Joe"
          gender "Male"
        end

        trait :female do
          name   "Jane"
          gender "Female"
        end

        factory :great_user do
          great
        end

        factory :admin, :traits => [:admin]

        factory :male_user do
          male

          factory :child_male_user do
            date_of_birth { Date.parse("1/1/2000") }
          end
        end

        factory :female, :traits => [:female] do
          trait :admin do
            admin true
            name "Judy"
          end

          factory :female_great_user do
            great
          end

          factory :female_admin_judy, :traits => [:admin]
        end

        factory :female_admin,            :traits => [:female, :admin]
        factory :female_after_male_admin, :traits => [:male, :female, :admin]
        factory :male_after_female_admin, :traits => [:female, :male, :admin]
      end

      trait :email do
        email { "#{name}@example.com" }
      end

      factory :user_with_email, :class => User, :traits => [:email] do
        name "Bill"
      end
    end
  end

  context "the parent class" do
    subject      { FactoryGirl.create(:user) }
    its(:name)   { should == "John" }
    its(:gender) { should be_nil }
    it           { should_not be_admin }
  end

  context "the child class with one trait" do
    subject      { FactoryGirl.create(:admin) }
    its(:name)   { should == "John" }
    its(:gender) { should be_nil }
    it           { should be_admin }
  end

  context "the other child class with one trait" do
    subject      { FactoryGirl.create(:female) }
    its(:name)   { should == "Jane" }
    its(:gender) { should == "Female" }
    it           { should_not be_admin }
  end

  context "the child with multiple traits" do
    subject      { FactoryGirl.create(:female_admin) }
    its(:name)   { should == "Jane" }
    its(:gender) { should == "Female" }
    it           { should be_admin }
  end

  context "the child with multiple traits and overridden attributes" do
    subject      { FactoryGirl.create(:female_admin, :name => "Jill", :gender => nil) }
    its(:name)   { should == "Jill" }
    its(:gender) { should be_nil }
    it           { should be_admin }
  end

  context "the child with multiple traits who override the same attribute" do
    context "when the male assigns name after female" do
      subject      { FactoryGirl.create(:male_after_female_admin) }
      its(:name)   { should == "Joe" }
      its(:gender) { should == "Male" }
      it           { should be_admin }
    end

    context "when the female assigns name after male" do
      subject      { FactoryGirl.create(:female_after_male_admin) }
      its(:name)   { should == "Jane" }
      its(:gender) { should == "Female" }
      it           { should be_admin }
    end
  end

  context "child class with scoped trait and inherited trait" do
    subject      { FactoryGirl.create(:female_admin_judy) }
    its(:name)   { should == "Judy" }
    its(:gender) { should == "Female" }
    it           { should be_admin }
  end

  context "factory using global trait" do
    subject     { FactoryGirl.create(:user_with_email) }
    its(:name)  { should == "Bill" }
    its(:email) { should == "Bill@example.com"}
  end

  context "factory created with alternate syntax for specifying trait" do
    subject      { FactoryGirl.create(:male_user) }
    its(:gender) { should == "Male" }
  end

  context "factory created with alternate syntax where trait name and attribute are the same" do
    subject     { FactoryGirl.create(:great_user) }
    its(:great) { should == "GREAT!!!" }
  end

  context "factory created with alternate syntax where trait name and attribute are the same and attribute is overridden" do
    subject     { FactoryGirl.create(:great_user, :great => "SORT OF!!!") }
    its(:great) { should == "SORT OF!!!" }
  end

  context "child factory created where trait attributes are inherited" do
    subject             { FactoryGirl.create(:child_male_user) }
    its(:gender)        { should == "Male" }
    its(:date_of_birth) { should == Date.parse("1/1/2000") }
  end

  context "factory outside of scope" do
    subject     { FactoryGirl.create(:user_without_admin_scoping) }
    it { expect { subject }.to raise_error(ArgumentError, "Trait not registered: admin_trait") }
  end

  context "child factory using grandparents' trait" do
    subject     { FactoryGirl.create(:female_great_user) }
    its(:great) { should == "GREAT!!!" }
  end
end

describe "traits with callbacks" do
  before do
    define_model("User", :name => :string)

    FactoryGirl.define do
      factory :user do
        name "John"

        trait :great do
          after_create {|user| user.name.upcase! }
        end

        trait :awesome do
          after_create {|user| user.name = "awesome" }
        end

        factory :caps_user, :traits => [:great]
        factory :awesome_user, :traits => [:great, :awesome]

        factory :caps_user_implicit_trait do
          great
        end
      end
    end
  end

  context "when the factory has a trait passed via arguments" do
    subject    { FactoryGirl.create(:caps_user) }
    its(:name) { should == "JOHN" }
  end

  context "when the factory has an implicit trait" do
    subject    { FactoryGirl.create(:caps_user_implicit_trait) }
    its(:name) { should == "JOHN" }
  end

  it "executes callbacks in the order assigned" do
    FactoryGirl.create(:awesome_user).name.should == "awesome"
  end
end

describe "traits added via strategy" do
  before do
    define_model("User", :name => :string, :admin => :boolean)

    FactoryGirl.define do
      factory :user do
        name "John"

        trait :admin do
          admin true
        end

        trait :great do
          after_create {|user| user.name.upcase! }
        end
      end
    end
  end

  context "adding traits in create" do
    subject { FactoryGirl.create(:user, :admin, :great, :name => "Joe") }

    its(:admin) { should be_true }
    its(:name)  { should == "JOE" }

    it "doesn't modify the user factory" do
      subject
      FactoryGirl.create(:user).should_not be_admin
      FactoryGirl.create(:user).name.should == "John"
    end
  end

  context "adding traits in build" do
    subject { FactoryGirl.build(:user, :admin, :great, :name => "Joe") }

    its(:admin) { should be_true }
    its(:name)  { should == "Joe" }
  end

  context "adding traits in attributes_for" do
    subject { FactoryGirl.attributes_for(:user, :admin, :great) }

    its([:admin]) { should be_true }
    its([:name])  { should == "John" }
  end

  context "adding traits in build_stubbed" do
    subject { FactoryGirl.build_stubbed(:user, :admin, :great, :name => "Jack") }

    its(:admin) { should be_true }
    its(:name)  { should == "Jack" }
  end

  context "adding traits in create_list" do
    subject { FactoryGirl.create_list(:user, 2, :admin, :great, :name => "Joe") }

    its(:length) { should == 2 }

    it "creates all the records" do
      subject.each do |record|
        record.admin.should be_true
        record.name.should == "JOE"
      end
    end
  end

  context "adding traits in build_list" do
    subject { FactoryGirl.build_list(:user, 2, :admin, :great, :name => "Joe") }

    its(:length) { should == 2 }

    it "builds all the records" do
      subject.each do |record|
        record.admin.should be_true
        record.name.should == "Joe"
      end
    end
  end
end

describe "traits and dynamic attributes that are applied simultaneously" do
  before do
    define_model("User", :name => :string, :email => :string, :combined => :string)

    FactoryGirl.define do
      trait :email do
        email { "#{name}@example.com" }
      end

      factory :user do
        name "John"
        email
        combined { "#{name} <#{email}>" }
      end
    end
  end

  subject        { FactoryGirl.build(:user) }
  its(:name)     { should == "John" }
  its(:email)    { should == "John@example.com" }
  its(:combined) { should == "John <John@example.com>" }
end

describe "applying inline traits" do
  before do
    define_model("User") do
      has_many :posts
    end

    define_model("Post", :user_id => :integer) do
      belongs_to :user
    end

    FactoryGirl.define do
      factory :user do
        trait :with_post do
          posts { [ Post.new ] }
        end
      end
    end
  end

  it "applies traits only to the instance generated for that call" do
    FactoryGirl.create(:user, :with_post).posts.should_not be_empty
    FactoryGirl.create(:user).posts.should be_empty
    FactoryGirl.create(:user, :with_post).posts.should_not be_empty
  end
end

describe "inline traits overriding existing attributes" do
  before do
    define_model("User", :status => :string)

    FactoryGirl.define do
      factory :user do
        status "pending"

        trait(:accepted) { status "accepted" }
        trait(:declined) { status "declined" }

        factory :declined_user, :traits => [:declined]
        factory :extended_declined_user, :traits => [:declined] do
          status "extended_declined"
        end
      end
    end
  end

  it "returns the default status" do
    FactoryGirl.build(:user).status.should == "pending"
  end

  it "prefers inline trait attributes over default attributes" do
    FactoryGirl.build(:user, :accepted).status.should == "accepted"
  end

  it "prefers traits on a factory over default attributes" do
    FactoryGirl.build(:declined_user).status.should == "declined"
  end

  it "prefers inline trait attributes over traits on a factory" do
    FactoryGirl.build(:declined_user, :accepted).status.should == "accepted"
  end

  it "prefers attributes on factories over attributes from non-inline traits" do
    FactoryGirl.build(:extended_declined_user).status.should == "extended_declined"
  end

  it "prefers inline traits over attributes on factories" do
    FactoryGirl.build(:extended_declined_user, :accepted).status.should == "accepted"
  end

  it "prefers overridden attributes over attributes from traits, inline traits, or attributes on factories" do
    FactoryGirl.build(:extended_declined_user, :accepted, :status => "completely overridden").status.should == "completely overridden"
  end
end
