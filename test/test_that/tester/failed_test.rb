# frozen_string_literal: true

require "test_helper"
require "support/fake_harness"
require "support/recording_runner"

module TestThat
  module Tester
    class FailedTest < Minitest::Test
      def test_runs_test_failed_command
        harness = FakeHarness.new(nil, "rspec --only-failures")
        runner = RecordingRunner.new
        TestThat::Tester::Failed.new(harness, runner).call

        assert_equal "rspec --only-failures", runner.last_command
      end
    end
  end
end
