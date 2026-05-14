# frozen_string_literal: true


module EacCeMultitool
  module Fs
    class RcloneSync
      class RcloneArgs
        acts_as_instance_method
        common_constructor :rclone_sync
        delegate :confirm?, :delete?, :excludes, :extra, :verbose?, :source, :target,
                 to: :rclone_sync

        # @return [Enumerable<String>]
        def result
          %w[delete confirm excludes log_level verbose extra].flat_map do |opt|
            send("#{opt}_args")
          end +
            source.to_rclone_args + target.to_rclone_args
        end

        # @return [Enumerable<String>]
        def confirm_args
          confirm? ? [] : ['--dry-run']
        end

        # @return [Enumerable<String>]
        def delete_args
          delete? ? ['sync', '--track-renames'] : ['copy']
        end

        # @return [Enumerable<String>]
        def excludes_args
          excludes.flat_map { |e| ['--exclude', e] }
        end

        # @return [Enumerable<String>]
        def extra_args
          return [] if extra.blank?

          extra.is_a?(::Enumerable) ? extra.to_a : ::Shellwords.split(extra.to_s)
        end

        # @return [Enumerable<String>]
        def log_level_args
          ['--log-level', 'INFO']
        end

        # @return [Enumerable<String>]
        def verbose_args
          verbose? ? [] : ['--use-json-log', '--stats=0']
        end
      end
        end
  end
end
