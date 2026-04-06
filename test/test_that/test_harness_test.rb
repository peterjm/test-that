# frozen_string_literal: true

require "test_helper"

class TestThat::TestHarnessRubyTest < Minitest::Test
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
    result = capture_io { @result = @harness.test_failed_command }
    assert_equal "false", @result
  end
end

class TestHarnessRailsTest < Minitest::Test
  def setup
    @harness = TestThat::TestHarness::Rails.new
  end

  def test_select_tests_filters_test_files
    files = ["test/models/user_test.rb", "app/models/user.rb"]
    assert_equal ["test/models/user_test.rb"], @harness.select_tests(files)
  end

  def test_select_tests_rejects_spec_files
    assert_equal [], @harness.select_tests(["spec/models/user_spec.rb"])
  end

  def test_test_all_command
    assert_equal "rails test:all", @harness.test_all_command
  end

  def test_test_files_command
    assert_equal "rails test test/models/user_test.rb test/controllers/posts_test.rb",
      @harness.test_files_command(["test/models/user_test.rb", "test/controllers/posts_test.rb"])
  end
end

class TestHarnessRspecTest < Minitest::Test
  def setup
    @harness = TestThat::TestHarness::Rspec.new
  end

  def test_select_tests_filters_spec_files
    files = ["spec/models/user_spec.rb", "app/models/user.rb", "spec/helpers/foo_spec.rb"]
    result = @harness.select_tests(files)
    assert_equal ["spec/models/user_spec.rb", "spec/helpers/foo_spec.rb"], result
  end

  def test_select_tests_allows_line_numbers
    assert_equal ["spec/models/user_spec.rb:42"], @harness.select_tests(["spec/models/user_spec.rb:42"])
  end

  def test_select_tests_rejects_test_files
    assert_equal [], @harness.select_tests(["test/models/user_test.rb"])
  end

  def test_test_all_command
    assert_equal "rspec", @harness.test_all_command
  end

  def test_test_failed_command
    assert_equal "rspec --only-failures", @harness.test_failed_command
  end

  def test_test_files_command
    assert_equal "rspec spec/models/user_spec.rb spec/helpers/foo_spec.rb",
      @harness.test_files_command(["spec/models/user_spec.rb", "spec/helpers/foo_spec.rb"])
  end
end

class TestHarnessUvPythonTest < Minitest::Test
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
end

class TestHarnessOverrideTest < Minitest::Test
  def test_delegates_enabled_to_base
    base = FakeHarness.new(enabled: true)
    override = TestThat::TestHarness::Override.new({ commands: {} }, base)
    assert override.enabled?
  end

  def test_delegates_enabled_false_to_base
    base = FakeHarness.new(enabled: false)
    override = TestThat::TestHarness::Override.new({ commands: {} }, base)
    refute override.enabled?
  end

  def test_delegates_select_tests_to_base
    base = FakeHarness.new(selected: ["spec/foo_spec.rb"])
    override = TestThat::TestHarness::Override.new({ commands: {} }, base)
    assert_equal ["spec/foo_spec.rb"], override.select_tests(["spec/foo_spec.rb", "app/foo.rb"])
  end

  def test_overrides_all_command
    base = FakeHarness.new(all_cmd: "rspec")
    override = TestThat::TestHarness::Override.new({ commands: { all: "make test-all" } }, base)
    assert_equal "make test-all", override.test_all_command
  end

  def test_falls_back_to_base_when_no_all_override
    base = FakeHarness.new(all_cmd: "rspec")
    override = TestThat::TestHarness::Override.new({ commands: {} }, base)
    assert_equal "rspec", override.test_all_command
  end

  def test_overrides_failed_command
    base = FakeHarness.new(failed_cmd: "rspec --only-failures")
    override = TestThat::TestHarness::Override.new({ commands: { failed: "make test-failed" } }, base)
    assert_equal "make test-failed", override.test_failed_command
  end

  def test_falls_back_to_base_when_no_failed_override
    base = FakeHarness.new(failed_cmd: "rspec --only-failures")
    override = TestThat::TestHarness::Override.new({ commands: {} }, base)
    assert_equal "rspec --only-failures", override.test_failed_command
  end

  def test_overrides_files_command_with_substitution
    base = FakeHarness.new
    override = TestThat::TestHarness::Override.new({ commands: { files: "make test FILES" } }, base)
    assert_equal "make test spec/foo_spec.rb spec/bar_spec.rb",
      override.test_files_command(["spec/foo_spec.rb", "spec/bar_spec.rb"])
  end

  def test_falls_back_to_base_when_no_files_override
    base = FakeHarness.new(files_cmd: "rspec spec/a.rb")
    override = TestThat::TestHarness::Override.new({ commands: {} }, base)
    assert_equal "rspec spec/a.rb", override.test_files_command(["spec/a.rb"])
  end

  private

  FakeHarness = Struct.new(:enabled, :selected, :all_cmd, :failed_cmd, :files_cmd, keyword_init: true) do
    def enabled? = enabled
    def select_tests(_files) = selected
    def test_all_command = all_cmd
    def test_failed_command = failed_cmd
    def test_files_command(_files) = files_cmd
  end
end
