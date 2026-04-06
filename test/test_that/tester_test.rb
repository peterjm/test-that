# frozen_string_literal: true

require "test_helper"

class TesterAllTest < Minitest::Test
  def test_runs_test_all_command
    harness = FakeHarness.new("rails test:all")
    runner = RecordingRunner.new
    TestThat::Tester::All.new(harness, runner).test

    assert_equal "rails test:all", runner.last_command
  end
end

class TesterFailedTest < Minitest::Test
  def test_runs_test_failed_command
    harness = FakeHarness.new(nil, "rspec --only-failures")
    runner = RecordingRunner.new
    TestThat::Tester::Failed.new(harness, runner).test

    assert_equal "rspec --only-failures", runner.last_command
  end
end

class TesterSelectedTest < Minitest::Test
  def test_runs_test_files_command
    harness = FakeHarness.new
    runner = RecordingRunner.new
    files = ["test/foo_test.rb"]
    TestThat::Tester::Selected.new(harness, runner, files).test

    assert_equal "test test/foo_test.rb", runner.last_command
  end
end

class TesterVerboseSelectedTest < Minitest::Test
  def test_prints_single_file
    harness = FakeHarness.new
    runner = RecordingRunner.new
    files = ["test/foo_test.rb"]

    output = capture_io { TestThat::Tester::VerboseSelected.new(harness, runner, files).test }.first
    assert_equal "Running tests for test/foo_test.rb\n", output
  end

  def test_prints_multiple_files
    harness = FakeHarness.new
    runner = RecordingRunner.new
    files = ["test/foo_test.rb", "test/bar_test.rb"]

    output = capture_io { TestThat::Tester::VerboseSelected.new(harness, runner, files).test }.first
    assert_includes output, "Running tests for:"
    assert_includes output, "  test/foo_test.rb"
    assert_includes output, "  test/bar_test.rb"
  end
end

class TesterEmptyTest < Minitest::Test
  def test_prints_no_tests_message_and_returns_true
    output = capture_io { assert TestThat::Tester::Empty.new.test }.first
    assert_equal "No tests to run\n", output
  end
end

class TesterErrorTest < Minitest::Test
  def test_prints_error_message_and_returns_false
    output = capture_io { refute TestThat::Tester::Error.new.test }.last
    assert_equal "Could not run tests; no compatible test environment detected\n", output
  end
end

class FakeHarness
  attr_reader :all_cmd, :failed_cmd

  def initialize(all_cmd = nil, failed_cmd = nil)
    @all_cmd = all_cmd
    @failed_cmd = failed_cmd
  end

  def test_all_command = all_cmd
  def test_failed_command = failed_cmd
  def test_files_command(files) = "test #{files.join(" ")}"
end

class RecordingRunner
  attr_reader :last_command

  def run(command)
    @last_command = command
  end
end
