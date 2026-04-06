# frozen_string_literal: true

class RecordingRunner
  attr_reader :last_command

  def run(command)
    @last_command = command
  end
end
