# frozen_string_literal: true

module TestThat
  module TestHarness
    class Base
      def initialize(verbose: false)
        @verbose = verbose
      end

      def enabled?
        raise NotImplementedError
      end

      def select_tests(_files)
        raise NotImplementedError
      end

      def test_all_command
        raise NotImplementedError
      end

      def test_failed_command
        raise NotImplementedError
      end

      def test_files_command(_files)
        raise NotImplementedError
      end

      def supports_keyword?
        false
      end
    end
  end
end
