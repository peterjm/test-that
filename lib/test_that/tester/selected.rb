# frozen_string_literal: true

module TestThat
  module Tester
    class Selected < Basic
      attr_reader :tests_to_run

      def initialize(test_harness, command_runner, tests_to_run)
        super(test_harness, command_runner)
        @tests_to_run = tests_to_run
      end

      def call
        run(test_harness.test_files_command(tests_to_run))
      end
    end
  end
end
