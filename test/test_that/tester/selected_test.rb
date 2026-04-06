# frozen_string_literal: true

require "test_helper"

class TestThat::Tester::SelectedTest < Minitest::Test
  def test_runs_test_files_command
    harness = FakeHarness.new
    runner = RecordingRunner.new
    files = ["test/foo_test.rb"]
    TestThat::Tester::Selected.new(harness, runner, files).test

    assert_equal "test test/foo_test.rb", runner.last_command
  end
end
