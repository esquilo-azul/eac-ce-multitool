# frozen_string_literal: true


module EacCeMultitool
  module Fs
    class RsyncSync
      class Path
        VALID_SCHEMES = %w[file ssh rsync].freeze
        DEFAULT_INSTALL_PORT = 22

        enable_simple_cache
        common_constructor :source

        def to_rsync_args
          validate!
          send("#{uri.scheme}_to_rsync_args")
        end

        delegate :to_s, to: :uri

        def validate!
          validate_scheme!
          validate_path!
        end

        def mkdirp
          env.command('mkdir', '-p', uri.path).execute!
        end

        private

        def escape_dir(string)
          string += '/' unless string.match?(%r{/\z})
          string
        end

        def file_to_rsync_args
          [escape_dir(uri.path)]
        end

        def rsync_to_rsync_args
          [escape_dir(uri.to_s)]
        end

        def ssh_to_rsync_args
          r = []
          r += ['-e', "ssh -p #{ssh_port}"] if ssh_port != DEFAULT_INSTALL_PORT
          r + [escape_dir("#{uri.user}@#{uri.host}:#{uri.path}")]
        end

        def ssh_port
          return nil unless uri.scheme == 'ssh'

          uri.port.if_present(DEFAULT_INSTALL_PORT)
        end

        def ssh_user_host
          return nil unless uri.scheme == 'ssh'

          "#{uri.user}@"
        end

        def uri_uncached
          r = if source.is_a?(::Addressable::URI)
                source.dup
              else
                ::Addressable::URI.parse(source)
              end
          r.scheme = 'file' if r.scheme.blank?
          r
        end

        def env_uncached
          case uri.scheme
          when 'file' then ::EacRubyUtils::Envs.local
          when 'ssh' then ::EacRubyUtils::Envs.ssh(uri)
          else raise "Unsupported scheme for \"env\" method: #{uri.scheme}"
          end
        end

        def validate_path!
          raise "Path is blank (URI: #{uri})" if uri.path.blank?
          raise 'Path cannot be "/"' if uri.path == '/'
        end

        def validate_scheme!
          return if VALID_SCHEMES.include?(uri.scheme)

          raise "Invalid scheme \"#{uri.scheme}\" (URI: #{uri})"
        end
      end
        end
  end
end
