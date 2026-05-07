# frozen_string_literal: true

module EacCeMultitool
  class UrlRunner
    class Decode
      runner_with :help, :output

      def run
        runner_context.call(:url_banner)
        run_output
      end

      def output_content
        "#{::CGI.unescape(runner_context.call(:url))}\n"
      end
    end
  end
end
