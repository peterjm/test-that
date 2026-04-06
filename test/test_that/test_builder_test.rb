# frozen_string_literal: true

require "test_helper"
require "tempfile"
require "json"

class TestBuilderTest < Minitest::Test
  def test_returns_error_when_no_harness_detected
    Dir.chdir(Dir.mktmpdir) do
      tester = TestThat::TestBuilder.build(base_options)
      assert_instance_of TestThat::Tester::Error, tester
    end
  end

  def test_returns_all_tester_when_all_flag_set
    in_ruby_project do
      tester = TestThat::TestBuilder.build(base_options(all: true))
      assert_instance_of TestThat::Tester::All, tester
    end
  end

  def test_returns_failed_tester_when_failed_flag_set
    in_ruby_project do
      tester = TestThat::TestBuilder.build(base_options(failed: true))
      assert_instance_of TestThat::Tester::Failed, tester
    end
  end

  def test_returns_selected_when_tests_match_harness
    in_ruby_project do
      FileUtils.mkdir_p("test/models")
      File.write("test/models/user_test.rb", "")

      tester = TestThat::TestBuilder.build(base_options(tests: ["test/models/user_test.rb"]))
      assert_instance_of TestThat::Tester::Selected, tester
    end
  end

  def test_returns_empty_when_no_tests_found
    in_ruby_project do
      tester = build_with_no_external_files(base_options(tests: []))
      assert_instance_of TestThat::Tester::Empty, tester
    end
  end

  def test_uses_dry_run_runner_when_flag_set
    in_ruby_project do
      tester = TestThat::TestBuilder.build(base_options(all: true, dry_run: true))
      assert_instance_of TestThat::CommandRunner::DryRun, tester.command_runner
    end
  end

  def test_uses_execute_runner_by_default
    in_ruby_project do
      tester = TestThat::TestBuilder.build(base_options(all: true))
      assert_instance_of TestThat::CommandRunner::Execute, tester.command_runner
    end
  end

  def test_merges_config_file_options
    in_ruby_project do
      config_path = write_config_file({ "all" => true })
      tester = TestThat::TestBuilder.build(base_options(config_file: config_path))
      assert_instance_of TestThat::Tester::All, tester
    end
  end

  def test_cli_options_take_precedence_over_config_file
    in_ruby_project do
      config_path = write_config_file({ "all" => true })
      tester = TestThat::TestBuilder.build(base_options(config_file: config_path, all: false, failed: true))
      assert_instance_of TestThat::Tester::Failed, tester
    end
  end

  def test_wraps_harness_with_override_when_configured
    in_ruby_project do
      override_config = { commands: { all: "custom test" } }
      tester = TestThat::TestBuilder.build(base_options(all: true, override: override_config))
      assert_instance_of TestThat::Tester::All, tester
      assert_equal "custom test", tester.test_harness.test_all_command
    end
  end

  private

  def base_options(**overrides)
    { tests: [], config_file: nil }.merge(overrides)
  end

  def in_ruby_project
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p("test")
        yield
      end
    end
  end

  def write_config_file(data)
    file = Tempfile.new([".test_that", ".json"])
    file.write(JSON.generate(data))
    file.close
    file.path
  end

  def build_with_no_external_files(options)
    builder = TestThat::TestBuilder.new(options)
    # Stub out external command dependencies
    builder.define_singleton_method(:related_tests) { [] }
    builder.define_singleton_method(:changed_tests) { [] }
    builder.build
  end
end
