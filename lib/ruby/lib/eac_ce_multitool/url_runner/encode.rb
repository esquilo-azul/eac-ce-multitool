# frozen_string_literal: true

module EacCeMultitool
  class UrlRunner
    class Encode
      runner_with :help, :output

      def run
        runner_context.call(:url_banner)
        run_output
      end

      def output_content
        "#{::CGI.escape(runner_context.call(:url))}\n"
      end
    end
  end
end
