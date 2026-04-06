# frozen_string_literal: true

module TestThat
  class ChangedFiles
    attr_reader :include_branch_commits

    def initialize(include_branch_commits)
      @include_branch_commits = include_branch_commits
    end

    def files
      content = if include_branch_commits
        `git-changed-files --include-branch-commits | related-files --stdin`
      else
        `git-changed-files | related-files --stdin`
      end
      content.split.map(&:strip)
    end
  end
end
