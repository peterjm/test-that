# frozen_string_literal: true

require "test_helper"

module TestThat
  module TestHarness
    class RubyTest < Minitest::Test
      def setup
        @harness = TestThat::TestHarness::Ruby.new
      end

      def test_select_tests_filters_to_test_files
        files = ["test/models/user_test.rb", "app/models/user.rb", "test/helpers/foo_test.rb"]
        result = @harness.select_tests(files)

        assert_equal ["test/models/user_test.rb", "test/helpers/foo_test.rb"], result
      end

      def test_select_tests_rejects_non_test_files
        assert_equal [], @harness.select_tests(["app/models/user.rb", "README.md"])
      end

      def test_select_tests_rejects_test_files_outside_test_dir
        assert_equal [], @harness.select_tests(["spec/models/user_test.rb"])
      end

      def test_test_all_command
        cmd = @harness.test_all_command

        assert_includes cmd, "ruby"
        assert_includes cmd, "-Itest"
        assert_includes cmd, "Dir.glob"
      end

      def test_test_files_command_strips_test_prefix
        cmd = @harness.test_files_command(["test/models/user_test.rb", "test/helpers/foo_test.rb"])

        assert_includes cmd, "ruby"
        assert_includes cmd, "-Itest"
        assert_includes cmd, "models/user_test.rb"
        assert_includes cmd, "helpers/foo_test.rb"
      end

      def test_test_files_command_contains_require_each
        cmd = @harness.test_files_command(["test/foo_test.rb"])

        assert_includes cmd, "ARGV.each"
      end

      def test_test_failed_command_returns_false
        capture_io { @result = @harness.test_failed_command }

        assert_equal "false", @result
      end
    end
  end
end
