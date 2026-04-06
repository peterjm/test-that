# frozen_string_literal: true

module TestThat
  module Tester
    class Empty
      def test
        puts "No tests to run"
        true
      end
    end
  end
end
