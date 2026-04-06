# frozen_string_literal: true

require "test_helper"
require "tempfile"
require "json"

module TestThat
  class ConfigFileTest < Minitest::Test
    def test_returns_empty_hash_when_filename_is_nil
      config = TestThat::ConfigFile.new(nil)

      assert_equal({}, config.options)
    end

    def test_returns_empty_hash_when_file_does_not_exist
      config = TestThat::ConfigFile.new("nonexistent.json")

      assert_equal({}, config.options)
    end

    def test_parses_json_file_with_symbolized_keys
      with_config_file({ "override" => { "commands" => { "all" => "make test" } } }) do |path|
        config = TestThat::ConfigFile.new(path)
        expected = { override: { commands: { all: "make test" } } }

        assert_equal expected, config.options
      end
    end

    def test_preserves_non_hash_values
      with_config_file({ "all" => true, "tests" => ["a.rb", "b.rb"] }) do |path|
        config = TestThat::ConfigFile.new(path)

        assert_equal({ all: true, tests: ["a.rb", "b.rb"] }, config.options)
      end
    end

    private

    def with_config_file(data)
      file = Tempfile.new([".test_that", ".json"])
      file.write(JSON.generate(data))
      file.close
      yield file.path
    ensure
      file.unlink
    end
  end
end
