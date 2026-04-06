# frozen_string_literal: true

require "test_helper"

class TestThat::ChangedFilesTest < Minitest::Test
  def test_returns_files_from_git_changed_files
    changed = TestThat::ChangedFiles.new(false)
    changed.define_singleton_method(:`) { |_| "test/foo_test.rb\ntest/bar_test.rb\n" }

    assert_equal ["test/foo_test.rb", "test/bar_test.rb"], changed.files
  end

  def test_includes_branch_commits_flag
    changed = TestThat::ChangedFiles.new(true)
    called_with = nil
    changed.define_singleton_method(:`) { |cmd| called_with = cmd; "test/baz_test.rb\n" }

    assert_equal ["test/baz_test.rb"], changed.files
    assert_includes called_with, "--include-branch-commits"
  end

  def test_does_not_include_branch_commits_by_default
    changed = TestThat::ChangedFiles.new(false)
    called_with = nil
    changed.define_singleton_method(:`) { |cmd| called_with = cmd; "" }

    changed.files
    refute_includes called_with, "--include-branch-commits"
  end

  def test_returns_empty_array_when_no_changes
    changed = TestThat::ChangedFiles.new(false)
    changed.define_singleton_method(:`) { |_| "" }

    assert_equal [], changed.files
  end
end
