# frozen_string_literal: true

require "test_helper"

class TestThat::Tester::AllTest < Minitest::Test
  def test_runs_test_all_command
    harness = FakeHarness.new("rails test:all")
    runner = RecordingRunner.new
    TestThat::Tester::All.new(harness, runner).test

    assert_equal "rails test:all", runner.last_command
  end
end
