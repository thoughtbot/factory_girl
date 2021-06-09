describe "Namespaced factories" do
  before do
    define_model("Category", name: :string)
    define_model("Movies::Category", name: :string)
  end

  context "by default" do
    before do
      FactoryBot.define do
        factory :category do
          name { "Classics" }
        end

        with_namespace(:Movies) do
          factory :category do
            name { "Emmy Winners" }
          end
        end
      end
    end

    it "creates a factory prefixed with the namespace" do
      instance = FactoryBot.build(:movies_category)

      expect(instance).to be_kind_of(Movies::Category)
      expect(instance.name).to eql("Emmy Winners")
    end

    it "does not collide with un-namespaced factories" do
      instance = FactoryBot.build(:category)

      expect(instance).to be_kind_of(Category)
      expect(instance.name).to eql("Classics")
    end
  end

  context "when prefixes are not required" do
    it "uses the namespaced factory without the prefix" do
      FactoryBot.define do
        with_namespace(:Movies, require_prefix: false) do
          factory :category do
            name { "Emmy Winners" }
          end
        end
      end

      instance = FactoryBot.build(:category)

      expect(instance).to be_kind_of(Movies::Category)
      expect(instance.name).to eql("Emmy Winners")
    end

    it "refuses to clobber existing factories" do
      FactoryBot.define do
        factory :category do
          name { "Classics" }
        end

        with_namespace(:Movies, require_prefix: false) do
          factory :category do
            name { "Emmy Winners" }
          end
        end
      end

      instance = FactoryBot.build(:category)

      expect(instance).to be_kind_of(Category)
      expect(instance.name).to eql("Classics")
    end
  end

  it "supports custom prefixes" do
    FactoryBot.define do
      with_namespace(:Movies, prefix: :m_) do
        factory :category do
          name { "Emmy Winners" }
        end
      end
    end

    instance = FactoryBot.build(:m_category)

    expect(instance).to be_kind_of(Movies::Category)
    expect(instance.name).to eql("Emmy Winners")
  end
end
