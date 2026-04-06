# frozen_string_literal: true

module TestThat
  module Tester
    class Failed < Basic
      def test
        run(test_harness.test_failed_command)
      end
    end
  end
end
