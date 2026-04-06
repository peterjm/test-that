# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "test_that"
require "minitest/autorun"

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
