# frozen_string_literal: true

module TestThat
  class ProjectRoot
    def initialize(harnesses:, default_directory: nil, ceiling: nil)
      @harnesses = harnesses
      @ceiling = ceiling
      @original_pwd = Dir.pwd
      apply_default_directory(default_directory)
      walk_to_project_root
    end

    def relative_to_root(paths)
      return paths unless @target_abs

      prefix = "#{@target_abs}/"
      paths.map do |path|
        abs = File.expand_path(path, @original_pwd)
        abs.start_with?(prefix) ? abs.delete_prefix(prefix) : path
      end
    end

    def from_original_pwd(&block)
      return yield if Dir.pwd == @original_pwd

      Dir.chdir(@original_pwd, &block)
    end

    private

    def apply_default_directory(dir)
      return unless dir && Dir.exist?(dir)

      @target_abs = File.expand_path(dir)
      Dir.chdir(@target_abs)
    end

    def walk_to_project_root
      root = find_project_root_ancestor
      return unless root && root != Dir.pwd

      @target_abs = root
      Dir.chdir(root)
    end

    def find_project_root_ancestor
      return nil unless @ceiling

      walk_ancestors_to(@ceiling) { |current| harness_enabled_in?(current) }
    end

    def walk_ancestors_to(ceiling)
      current = Dir.pwd
      loop do
        return current if yield(current)
        break if current == ceiling

        parent = File.dirname(current)
        break if parent == current

        current = parent
      end
      nil
    end

    def harness_enabled_in?(dir)
      Dir.chdir(dir) { @harnesses.any?(&:enabled?) }
    end
  end
end
