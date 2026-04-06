# frozen_string_literal: true

require "test_helper"

module TestThat
  module TestHarness
    class RailsTest < Minitest::Test
      def setup
        @harness = TestThat::TestHarness::Rails.new
      end

      def test_select_tests_filters_test_files
        files = ["test/models/user_test.rb", "app/models/user.rb"]

        assert_equal ["test/models/user_test.rb"], @harness.select_tests(files)
      end

      def test_select_tests_rejects_spec_files
        assert_equal [], @harness.select_tests(["spec/models/user_spec.rb"])
      end

      def test_test_all_command
        assert_equal "rails test:all", @harness.test_all_command
      end

      def test_test_files_command
        assert_equal "rails test test/models/user_test.rb test/controllers/posts_test.rb",
                     @harness.test_files_command(["test/models/user_test.rb", "test/controllers/posts_test.rb"])
      end
    end
  end
end
