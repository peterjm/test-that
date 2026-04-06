# frozen_string_literal: true

module TestThat
  class TestBuilder
    class << self
      def build(options)
        new(options).build
      end
    end

    attr_reader :options

    def initialize(options)
      @options = options
      @options = ConfigFile.new(options[:config_file]).options.merge(options)
    end

    def build # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      if no_test_harness?
        Tester::Error.new
      elsif test_all?
        Tester::All.new(test_harness, command_runner)
      elsif test_failed?
        Tester::Failed.new(test_harness, command_runner)
      elsif selected_tests.any?
        Tester::Selected.new(test_harness, command_runner, selected_tests)
      elsif related_tests.any?
        Tester::VerboseSelected.new(test_harness, command_runner, related_tests)
      elsif changed_tests.any?
        Tester::VerboseSelected.new(test_harness, command_runner, changed_tests)
      else
        Tester::Empty.new
      end
    end

    private

    def no_test_harness?
      test_harness.nil?
    end

    def test_all?
      options[:all]
    end

    def test_failed?
      options[:failed]
    end

    def dry_run?
      options[:dry_run]
    end

    def selected_tests
      @selected_tests ||= test_harness.select_tests(options[:tests])
    end

    def related_tests
      @related_tests ||= begin
        files = RelatedFiles.new(options[:tests]).files
        test_harness.select_tests(files)
      end
    end

    def changed_tests
      @changed_tests ||= begin
        files = ChangedFiles.new(options[:include_branch_commits]).files
        test_harness.select_tests(files)
      end
    end

    def test_harness
      @test_harness ||= begin
        harness = test_harnesses.detect(&:enabled?)
        harness = TestHarness::Override.new(options[:override], harness) if options[:override]
        harness
      end
    end

    def command_runner
      if dry_run?
        CommandRunner::DryRun.new
      else
        CommandRunner::Execute.new
      end
    end

    def test_harnesses
      [
        TestHarness::Rails.new,
        TestHarness::Ruby.new,
        TestHarness::Rspec.new,
        TestHarness::UvPython.new
      ]
    end
  end
end
