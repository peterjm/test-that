# frozen_string_literal: true

module TestThat
  module Tester
    class Error
      def initialize(message)
        @message = message
      end

      def call
        warn @message
        false
      end
    end
  end
end
