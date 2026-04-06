# frozen_string_literal: true

require "json"

module TestThat
  class ConfigFile
    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def options
      if filename && File.exist?(filename)
        symbolize_keys(JSON.parse(File.read(filename)))
      else
        {}
      end
    end

    private

    def symbolize_keys(hash)
      hash
        .transform_keys { |k| k.to_sym }
        .transform_values { |v| v.is_a?(Hash) ? symbolize_keys(v) : v }
    end
  end
end
