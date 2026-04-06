# frozen_string_literal: true

require "test_helper"

class TestThat::Tester::FailedTest < Minitest::Test
  def test_runs_test_failed_command
    harness = FakeHarness.new(nil, "rspec --only-failures")
    runner = RecordingRunner.new
    TestThat::Tester::Failed.new(harness, runner).test

    assert_equal "rspec --only-failures", runner.last_command
  end
end
