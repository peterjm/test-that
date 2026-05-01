# frozen_string_literal: true

require "tmpdir"
require "fileutils"

module TmpdirHelpers
  def in_tmpdir
    Dir.mktmpdir do |tmpdir|
      original = Dir.pwd
      Dir.chdir(tmpdir)
      yield(Dir.pwd)
    ensure
      Dir.chdir(original) if original
    end
  end
end
