# frozen_string_literal: true

require "test_helper"
require "support/fake_harness"
require "support/recording_runner"

module TestThat
  module Tester
    class AllTest < Minitest::Test
      def test_runs_test_all_command
        harness = FakeHarness.new("rails test:all")
        runner = RecordingRunner.new
        TestThat::Tester::All.new(harness, runner).call

        assert_equal "rails test:all", runner.last_command
      end
    end
  end
end
