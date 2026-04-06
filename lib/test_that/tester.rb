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

    class All < Basic
      def test
        run(test_harness.test_all_command)
      end
    end

    class Failed < Basic
      def test
        run(test_harness.test_failed_command)
      end
    end

    class Selected < Basic
      attr_reader :tests_to_run

      def initialize(test_harness, command_runner, tests_to_run)
        super(test_harness, command_runner)
        @tests_to_run = tests_to_run
      end

      def test
        run(test_harness.test_files_command(tests_to_run))
      end
    end

    class VerboseSelected < Selected
      def test
        print_tests
        super
      end

      private

      def print_tests
        if tests_to_run.size > 1
          puts "Running tests for:"
          tests_to_run.each { |f| puts "  #{f}" }
        else
          puts "Running tests for #{tests_to_run.first}"
        end
      end
    end

    class Empty
      def test
        puts "No tests to run"
        true
      end
    end

    class Error
      def test
        warn "Could not run tests; no compatible test environment detected"
        false
      end
    end
  end
end
