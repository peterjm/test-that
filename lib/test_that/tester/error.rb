# frozen_string_literal: true

module TestThat
  module Tester
    class Error
      def call
        warn "Could not run tests; no compatible test environment detected"
        false
      end
    end
  end
end
