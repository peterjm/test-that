# frozen_string_literal: true

require "test_helper"

module TestThat
  module Tester
    class ErrorTest < Minitest::Test
      def test_prints_error_message_and_returns_false
        output = capture_io { refute TestThat::Tester::Error.new("boom").call }.last

        assert_equal "boom\n", output
      end
    end
  end
end
