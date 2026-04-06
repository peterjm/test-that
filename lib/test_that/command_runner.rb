# frozen_string_literal: true

module TestThat
  module CommandRunner
    class Execute
      def run(command)
        exec(command)
      end
    end

    class DryRun
      def run(command)
        puts command
      end
    end
  end
end
