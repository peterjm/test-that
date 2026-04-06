# frozen_string_literal: true

require "test_helper"

module TestThat
  class RelatedFilesTest < Minitest::Test
    def test_returns_related_files_for_selected_files
      related = TestThat::RelatedFiles.new(["app/models/user.rb", "app/models/post.rb"])
      called_with = nil
      related.define_singleton_method(:`) do |cmd|
        called_with = cmd
        "test/models/user_test.rb\ntest/models/post_test.rb\n"
      end

      assert_equal ["test/models/user_test.rb", "test/models/post_test.rb"], related.files
      assert_equal "related-files app/models/user.rb app/models/post.rb", called_with
    end

    def test_returns_empty_array_when_no_related_files
      related = TestThat::RelatedFiles.new(["README.md"])
      related.define_singleton_method(:`) { |_| "" }

      assert_equal [], related.files
    end
  end
end
