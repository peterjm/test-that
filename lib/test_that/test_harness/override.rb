# frozen_string_literal: true

module TestThat
  module TestHarness
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
