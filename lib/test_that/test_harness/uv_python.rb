# frozen_string_literal: true

module TestThat
  module TestHarness
    class UvPython < Base
      TEST_REGEX = %r{(?:\A|/)([^/]+_test|test_[^/]+)\.py\z}

      def initialize(verbose: false, keyword: nil)
        super(verbose: verbose)
      end

      def enabled?
        File.exist?("pyproject.toml")
      end

      def select_tests(files)
        files.flat_map { |f| Dir.exist?(f) ? test_files_in_directory(f) : f }.grep(TEST_REGEX)
      end

      def test_all_command
        build_test_command
      end

      def test_failed_command
        build_test_command("--lf")
      end

      def test_files_command(files)
        build_test_command(*files)
      end

      private

      def test_files_in_directory(directory)
        Dir.glob(File.join(directory, "**/*_test.py").to_s) + Dir.glob(File.join(directory, "**/test_*.py").to_s)
      end

      def build_test_command(*args)
        args << "-v" if @verbose
        ["uv", "run", "pytest", *args].join(" ")
      end
    end
  end
end
