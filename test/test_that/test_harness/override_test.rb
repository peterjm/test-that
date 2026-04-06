# frozen_string_literal: true

require "test_helper"

module TestThat
  module TestHarness
    class OverrideTest < Minitest::Test
      def test_delegates_enabled_to_base
        base = FakeHarness.new(enabled: true)
        override = TestThat::TestHarness::Override.new({ commands: {} }, base)

        assert_predicate override, :enabled?
      end

      def test_delegates_enabled_false_to_base
        base = FakeHarness.new(enabled: false)
        override = TestThat::TestHarness::Override.new({ commands: {} }, base)

        refute_predicate override, :enabled?
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

      FakeHarness = Struct.new(:enabled, :selected, :all_cmd, :failed_cmd, :files_cmd, keyword_init: true) do
        def enabled? = enabled
        def select_tests(_files) = selected
        def test_all_command = all_cmd
        def test_failed_command = failed_cmd
        def test_files_command(_files) = files_cmd
      end
    end
  end
end
