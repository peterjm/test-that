# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module TestThat
  module TestHarness
    class UvPythonTest < Minitest::Test
      def setup
        @harness = TestThat::TestHarness::UvPython.new
      end

      def test_enabled_when_pyproject_toml_present
        Dir.mktmpdir do |dir|
          File.write(File.join(dir, "pyproject.toml"), "")

          Dir.chdir(dir) do
            assert_predicate @harness, :enabled?
          end
        end
      end

      def test_not_enabled_without_pyproject_toml
        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            refute_predicate @harness, :enabled?
          end
        end
      end

      def test_select_tests_matches_test_prefix_files
        assert_equal ["test_foo.py"], @harness.select_tests(["test_foo.py"])
      end

      def test_select_tests_matches_test_suffix_files
        assert_equal ["foo_test.py"], @harness.select_tests(["foo_test.py"])
      end

      def test_select_tests_matches_files_in_nested_directories
        assert_equal ["sub/test_foo.py"], @harness.select_tests(["sub/test_foo.py"])
      end

      def test_select_tests_rejects_non_test_files
        assert_equal [], @harness.select_tests(["foo.py", "conftest.py"])
      end

      def test_test_all_command
        assert_equal "uv run pytest", @harness.test_all_command
      end

      def test_test_failed_command
        assert_equal "uv run pytest --lf", @harness.test_failed_command
      end

      def test_test_files_command
        cmd = @harness.test_files_command(["test_foo.py", "bar_test.py"])

        assert_equal "uv run pytest test_foo.py bar_test.py", cmd
      end

      def test_test_files_command_includes_verbose_flag_when_verbose
        cmd = TestThat::TestHarness::UvPython.new(verbose: true).test_files_command(["test_foo.py"])

        assert_equal "uv run pytest test_foo.py -v", cmd
      end

      def test_test_files_command_includes_keyword_when_set
        cmd = TestThat::TestHarness::UvPython.new(keyword: "foo and not bar").test_files_command(["test_x.py"])

        assert_equal "uv run pytest test_x.py -k foo and not bar", cmd
      end

      def test_test_all_command_includes_keyword_when_set
        cmd = TestThat::TestHarness::UvPython.new(keyword: "foo").test_all_command

        assert_equal "uv run pytest -k foo", cmd
      end

      def test_test_failed_command_includes_keyword_when_set
        cmd = TestThat::TestHarness::UvPython.new(keyword: "foo").test_failed_command

        assert_equal "uv run pytest --lf -k foo", cmd
      end
    end
  end
end
