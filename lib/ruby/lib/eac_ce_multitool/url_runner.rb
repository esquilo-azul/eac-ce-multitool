# frozen_string_literal: true

module EacCeMultitool
  class UrlRunner
    require_sub __FILE__

    runner_with :help, :subcommands do
      desc 'Utilidades para URL'
      pos_arg :url
      subcommands
    end

    delegate :url, to: :parsed

    def url_banner
      infov 'Source URL', url
    end
  end
end
