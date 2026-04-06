# frozen_string_literal: true

require "test_helper"

class CommandRunnerTest < Minitest::Test
  def test_dry_run_prints_command
    runner = TestThat::CommandRunner::DryRun.new
    output = capture_io { runner.run("rails test") }.first
    assert_equal "rails test\n", output
  end
end
