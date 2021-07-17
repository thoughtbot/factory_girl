module FactoryBot
  module Strategy
    class AttributesFor
      def association(runner)
        nil
      end

      def result(evaluation)
        evaluation.hash
      end
    end
  end
end
