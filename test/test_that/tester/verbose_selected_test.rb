# frozen_string_literal: true

require "test_helper"

class TestThat::Tester::VerboseSelectedTest < Minitest::Test
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
