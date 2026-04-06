# frozen_string_literal: true

module TestThat
  module TestHarness
    class Ruby
      REQUIRE_ALL_TESTS = '-e "Dir.glob(\"**/*_test.rb\", base: \"test\"){|f| require f}"'
      REQUIRE_EACH_TEST = '-e "ARGV.each{|f| require f}"'

      def enabled?
        File.directory?("test")
      end

      def select_tests(files)
        files.flat_map { |f| Dir.exist?(f) ? Dir.glob(File.join(f, "**/*_test.rb").to_s) : f }.grep(%r{^test/.*_test\.rb$})
      end

      def test_all_command
        ["ruby", "-Itest", REQUIRE_ALL_TESTS].join(" ")
      end

      def test_failed_command
        puts "Re-running failures not available for this test harness"
        "false"
      end

      def test_files_command(files)
        files_relative_to_test_dir = files.map { |f| f.sub(%r{\Atest/}, "") }
        ["ruby", "-Itest", REQUIRE_EACH_TEST, *files_relative_to_test_dir].join(" ")
      end
    end

    class Rails
      def enabled?
        File.directory?("test") && File.exist?("config/application.rb")
      end

      def select_tests(files)
        files.grep(%r{^test/.*_test\.rb$})
      end

      def test_all_command
        "rails test:all"
      end

      def test_failed_command
        puts "Re-running failures not available for this test harness"
        "false"
      end

      def test_files_command(files)
        ["rails", "test", *files].join(" ")
      end
    end

    class Rspec
      def enabled?
        File.directory?("spec")
      end

      def select_tests(files)
        files.flat_map { |f| Dir.exist?(f) ? Dir.glob(File.join(f, "**/*_spec.rb").to_s) : f }.grep(%r{^spec/.*_spec\.rb(:\d+)?$})
      end

      def test_all_command
        "rspec"
      end

      def test_failed_command
        "rspec --only-failures"
      end

      def test_files_command(files)
        ["rspec", *files].join(" ")
      end
    end

    class UvPython
      TEST_REGEX = %r{([^/]+_test|test_[^/]+)\.py$}

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
        ["uv", "run", "--directory", "py", "pytest", *args].join(" ")
      end
    end

    class Override
      def initialize(config, base)
        @config = config
        @base = base
      end

      def enabled?
        @base.enabled?
      end

      def select_tests(files)
        @base.select_tests(files)
      end

      def test_all_command
        command(:all) || @base.test_all_command
      end

      def test_failed_command
        command(:failed) || @base.test_failed_command
      end

      def test_files_command(files)
        command(:files)&.sub("FILES", files.join(" ")) || @base.test_files_command(files)
      end

      private

      def command(command)
        @config[:commands][command]
      end
    end
  end
end
