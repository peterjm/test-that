# frozen_string_literal: true

require "test_helper"
require "support/tmpdir_helpers"

module TestThat
  class ProjectRootTest < Minitest::Test
    include TmpdirHelpers

    def test_default_directory_chdirs_into_subdirectory
      in_tmpdir do |dir|
        FileUtils.mkdir_p("py")
        File.write("py/pyproject.toml", "")

        ProjectRoot.new(harnesses: harnesses, default_directory: "py")

        assert_equal File.join(dir, "py"), Dir.pwd
      end
    end

    def test_default_directory_translates_paths_into_subdirectory
      in_tmpdir do
        FileUtils.mkdir_p("py")
        File.write("py/pyproject.toml", "")
        File.write("py/test_foo.py", "")

        root = ProjectRoot.new(harnesses: harnesses, default_directory: "py")

        assert_equal ["test_foo.py"], root.relative_to_root(["py/test_foo.py"])
      end
    end

    def test_default_directory_leaves_outside_paths_unchanged
      in_tmpdir do
        FileUtils.mkdir_p("py")
        File.write("py/pyproject.toml", "")

        root = ProjectRoot.new(harnesses: harnesses, default_directory: "py")

        assert_equal ["other/test_bar.py"], root.relative_to_root(["other/test_bar.py"])
      end
    end

    def test_default_directory_falls_back_when_directory_missing
      in_tmpdir do |dir|
        ProjectRoot.new(harnesses: harnesses, default_directory: "py")

        assert_equal dir, Dir.pwd
      end
    end

    def test_walks_up_to_find_harness
      in_tmpdir do |ceiling|
        FileUtils.mkdir_p("py/some/sub")
        File.write("py/pyproject.toml", "")
        Dir.chdir("py/some/sub")

        ProjectRoot.new(harnesses: harnesses, ceiling: ceiling)

        assert_equal File.join(ceiling, "py"), Dir.pwd
      end
    end

    def test_walk_up_stops_at_ceiling
      in_tmpdir do |outer|
        # `test/` at outer/ would trigger the Ruby harness if walk-up escaped the ceiling.
        FileUtils.mkdir_p("test")
        FileUtils.mkdir_p("subtree/inner")
        Dir.chdir("subtree")
        ceiling = Dir.pwd
        Dir.chdir("inner")

        ProjectRoot.new(harnesses: ruby_and_python_harnesses, ceiling: ceiling)

        assert Dir.pwd.start_with?(ceiling), "expected cwd inside #{ceiling}, got #{Dir.pwd}"
        refute_equal outer, Dir.pwd
      end
    end

    def test_walk_up_checks_ceiling_itself
      in_tmpdir do |ceiling|
        File.write("pyproject.toml", "")
        FileUtils.mkdir_p("sub")
        Dir.chdir("sub")

        ProjectRoot.new(harnesses: harnesses, ceiling: ceiling)

        assert_equal ceiling, Dir.pwd
      end
    end

    def test_no_walk_up_without_ceiling
      in_tmpdir do
        FileUtils.mkdir_p("py/sub")
        File.write("py/pyproject.toml", "")
        Dir.chdir("py/sub")
        expected = Dir.pwd

        ProjectRoot.new(harnesses: harnesses)

        assert_equal expected, Dir.pwd
      end
    end

    def test_from_original_pwd_runs_block_at_original_pwd
      in_tmpdir do |ceiling|
        FileUtils.mkdir_p("py/some/sub")
        File.write("py/pyproject.toml", "")
        Dir.chdir("py/some/sub")
        starting = Dir.pwd

        root = ProjectRoot.new(harnesses: harnesses, ceiling: ceiling)

        refute_equal starting, Dir.pwd

        captured = root.from_original_pwd { Dir.pwd }

        assert_equal starting, captured
      end
    end

    private

    def harnesses
      [TestHarness::UvPython.new]
    end

    def ruby_and_python_harnesses
      [TestHarness::Ruby.new, TestHarness::UvPython.new]
    end
  end
end
