# frozen_string_literal: true

module EacCeMultitool
  class UrlRunner
    class Fields
      runner_with :help, :output

      def run
        runner_context.call(:url_banner)
        run_output
      end

      def output_content
        fields.to_yaml
      end

      def fields
        x = ::Addressable::URI.parse(runner_context.call(:url))
        r = %w[scheme user password host port path query].index_with { |k| x.send(k) }
        r['query'] = x.query_values.if_present({}).map { |k, v| [k, v] }.sort.to_h
        r
      end
    end
  end
end
