# frozen_string_literal: true

module TestThat
  module Tester
    class Failed < Basic
      def call
        run(test_harness.test_failed_command)
      end
    end
  end
end
