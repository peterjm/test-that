# frozen_string_literal: true

module TestThat
  module TestHarness
    class UvPython
      TEST_REGEX = %r{([^/]+_test|test_[^/]+)\.py$}

      def initialize(verbose: false)
        @verbose = verbose
      end

      def enabled?
        File.exist?("py/pyproject.toml")
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
        args = args.map { |a| a.sub(%r{\Apy/}, "") }
        args << "-v" if @verbose
        ["uv", "run", "--directory", "py", "pytest", *args].join(" ")
      end
    end
  end
end
