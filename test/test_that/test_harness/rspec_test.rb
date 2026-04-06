# frozen_string_literal: true

require "test_helper"

module TestThat
  module TestHarness
    class RspecTest < Minitest::Test
      def setup
        @harness = TestThat::TestHarness::Rspec.new
      end

      def test_select_tests_filters_spec_files
        files = ["spec/models/user_spec.rb", "app/models/user.rb", "spec/helpers/foo_spec.rb"]
        result = @harness.select_tests(files)

        assert_equal ["spec/models/user_spec.rb", "spec/helpers/foo_spec.rb"], result
      end

      def test_select_tests_allows_line_numbers
        assert_equal ["spec/models/user_spec.rb:42"], @harness.select_tests(["spec/models/user_spec.rb:42"])
      end

      def test_select_tests_rejects_test_files
        assert_equal [], @harness.select_tests(["test/models/user_test.rb"])
      end

      def test_test_all_command
        assert_equal "rspec", @harness.test_all_command
      end

      def test_test_failed_command
        assert_equal "rspec --only-failures", @harness.test_failed_command
      end

      def test_test_files_command
        assert_equal "rspec spec/models/user_spec.rb spec/helpers/foo_spec.rb",
                     @harness.test_files_command(["spec/models/user_spec.rb", "spec/helpers/foo_spec.rb"])
      end
    end
  end
end
