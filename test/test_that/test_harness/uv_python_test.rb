# frozen_string_literal: true

require "test_helper"

module TestThat
  module TestHarness
    class UvPythonTest < Minitest::Test
      def setup
        @harness = TestThat::TestHarness::UvPython.new
      end

      def test_select_tests_matches_test_prefix_files
        assert_equal ["py/test_foo.py"], @harness.select_tests(["py/test_foo.py"])
      end

      def test_select_tests_matches_test_suffix_files
        assert_equal ["py/foo_test.py"], @harness.select_tests(["py/foo_test.py"])
      end

      def test_select_tests_rejects_non_test_files
        assert_equal [], @harness.select_tests(["py/foo.py", "py/conftest.py"])
      end

      def test_test_all_command
        assert_equal "uv run --directory py pytest", @harness.test_all_command
      end

      def test_test_failed_command
        assert_equal "uv run --directory py pytest --lf", @harness.test_failed_command
      end

      def test_test_files_command_strips_py_prefix
        cmd = @harness.test_files_command(["py/test_foo.py", "py/bar_test.py"])

        assert_equal "uv run --directory py pytest test_foo.py bar_test.py", cmd
      end

      def test_test_files_command_includes_verbose_flag_when_verbose
        cmd = TestThat::TestHarness::UvPython.new(verbose: true).test_files_command(["py/test_foo.py"])

        assert_equal "uv run --directory py pytest test_foo.py -v", cmd
      end
    end
  end
end
