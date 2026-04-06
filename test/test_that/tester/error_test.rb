# frozen_string_literal: true

require "test_helper"

class TestThat::Tester::ErrorTest < Minitest::Test
  def test_prints_error_message_and_returns_false
    output = capture_io { refute TestThat::Tester::Error.new.test }.last
    assert_equal "Could not run tests; no compatible test environment detected\n", output
  end
end
