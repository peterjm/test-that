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
      apply_default_directory
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
      @selected_tests ||= filter_tests(options[:tests] || [])
    end

    def related_tests
      @related_tests ||= filter_tests(related_files)
    end

    def changed_tests
      @changed_tests ||= filter_tests(changed_files)
    end

    def related_files
      @related_files ||= from_original_pwd { RelatedFiles.new(options[:tests] || []).files }
    end

    def changed_files
      @changed_files ||= from_original_pwd { ChangedFiles.new(options[:include_branch_commits]).files }
    end

    def filter_tests(paths)
      test_harness.select_tests(relative_to_default_directory(paths))
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
        TestHarness::Rails.new(verbose: verbose?),
        TestHarness::Ruby.new(verbose: verbose?),
        TestHarness::Rspec.new(verbose: verbose?),
        TestHarness::UvPython.new(verbose: verbose?)
      ]
    end

    def verbose?
      options[:verbose]
    end

    def apply_default_directory
      @original_pwd = Dir.pwd
      dir = options[:default_directory]
      return unless dir && Dir.exist?(dir)

      @target_abs = File.expand_path(dir)
      Dir.chdir(@target_abs)
    end

    def relative_to_default_directory(paths)
      return paths unless @target_abs

      prefix = "#{@target_abs}/"
      paths.map do |path|
        abs = File.expand_path(path, @original_pwd)
        abs.start_with?(prefix) ? abs.delete_prefix(prefix) : path
      end
    end

    def from_original_pwd(&block)
      return yield if Dir.pwd == @original_pwd

      Dir.chdir(@original_pwd, &block)
    end
  end
end
