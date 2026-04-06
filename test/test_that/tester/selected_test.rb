# frozen_string_literal: true

require "test_helper"
require "support/fake_harness"
require "support/recording_runner"

module TestThat
  module Tester
    class SelectedTest < Minitest::Test
      def test_runs_test_files_command
        harness = FakeHarness.new
        runner = RecordingRunner.new
        files = ["test/foo_test.rb"]
        TestThat::Tester::Selected.new(harness, runner, files).call

        assert_equal "test test/foo_test.rb", runner.last_command
      end
    end
  end
end
