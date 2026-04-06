# frozen_string_literal: true

module TestThat
  module Tester
    class Basic
      attr_reader :test_harness, :command_runner

      def initialize(test_harness, command_runner)
        @test_harness = test_harness
        @command_runner = command_runner
      end

      def run(command)
        command_runner.run(command)
      end
    end
  end
end
