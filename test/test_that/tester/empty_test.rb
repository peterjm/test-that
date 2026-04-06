# frozen_string_literal: true

require "test_helper"

module TestThat
  module Tester
    class EmptyTest < Minitest::Test
      def test_prints_no_tests_message_and_returns_true
        output = capture_io { assert TestThat::Tester::Empty.new.call }.first

        assert_equal "No tests to run\n", output
      end
    end
  end
end
