# frozen_string_literal: true

module TestThat
  module TestHarness
    class Ruby < Base
      REQUIRE_ALL_TESTS = '-e "Dir.glob(\"**/*_test.rb\", base: \"test\"){|f| require f}"'
      REQUIRE_EACH_TEST = '-e "ARGV.each{|f| require f}"'

      def enabled?
        File.directory?("test")
      end

      def select_tests(files)
        files.flat_map do |f|
          Dir.exist?(f) ? Dir.glob(File.join(f, "**/*_test.rb").to_s) : f
        end.grep(%r{^test/.*_test\.rb$})
      end

      def test_all_command
        parts = ["ruby", "-Itest", REQUIRE_ALL_TESTS]
        parts += ["--", "-v"] if @verbose
        parts.join(" ")
      end

      def test_failed_command
        puts "Re-running failures not available for this test harness"
        "false"
      end

      def test_files_command(files)
        files_relative_to_test_dir = files.map { |f| f.sub(%r{\Atest/}, "") }
        parts = ["ruby", "-Itest", REQUIRE_EACH_TEST, *files_relative_to_test_dir]
        parts << "-v" if @verbose
        parts.join(" ")
      end
    end
  end
end
