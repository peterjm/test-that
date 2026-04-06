# frozen_string_literal: true

module TestThat
  module TestHarness
    class Rails
      def enabled?
        File.directory?("test") && File.exist?("config/application.rb")
      end

      def select_tests(files)
        files.grep(%r{^test/.*_test\.rb$})
      end

      def test_all_command
        "rails test:all"
      end

      def test_failed_command
        puts "Re-running failures not available for this test harness"
        "false"
      end

      def test_files_command(files)
        ["rails", "test", *files].join(" ")
      end
    end
  end
end
