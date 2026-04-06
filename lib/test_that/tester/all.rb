# frozen_string_literal: true

module TestThat
  module Tester
    class All < Basic
      def call
        run(test_harness.test_all_command)
      end
    end
  end
end
