# frozen_string_literal: true

module TestThat
  class RelatedFiles
    attr_reader :selected_files

    def initialize(selected_files)
      @selected_files = selected_files
    end

    def files
      content = `related-files #{selected_files.join(" ")}`
      content.split.map(&:strip)
    end
  end
end
