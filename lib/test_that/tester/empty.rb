# frozen_string_literal: true

module TestThat
  module Tester
    class Empty
      def call
        puts "No tests to run"
        true
      end
    end
  end
end
