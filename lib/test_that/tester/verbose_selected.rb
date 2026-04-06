# frozen_string_literal: true

module TestThat
  module Tester
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
  end
end
