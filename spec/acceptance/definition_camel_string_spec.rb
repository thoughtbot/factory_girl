describe "an instance generated by a factory named a camel case string " do
  before do
    define_model("UserModel")

    FactoryGirl.define do
      factory "UserModel", class: UserModel
    end
  end

  it "registers the UserModel factory" do
    expect(FactoryGirl.factory_by_name("UserModel")).to be_a(FactoryGirl::Factory)
  end
end
