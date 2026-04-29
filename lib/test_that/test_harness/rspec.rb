# frozen_string_literal: true

module TestThat
  module TestHarness
    class Rspec
      def initialize(verbose: false)
        @verbose = verbose
      end

      def enabled?
        File.directory?("spec")
      end

      def select_tests(files)
        files.flat_map do |f|
          Dir.exist?(f) ? Dir.glob(File.join(f, "**/*_spec.rb").to_s) : f
        end.grep(%r{^spec/.*_spec\.rb(:\d+)?$})
      end

      def test_all_command
        with_verbose("rspec")
      end

      def test_failed_command
        with_verbose("rspec --only-failures")
      end

      def test_files_command(files)
        with_verbose(["rspec", *files].join(" "))
      end

      private

      def with_verbose(command)
        @verbose ? "#{command} --format documentation" : command
      end
    end
  end
end
