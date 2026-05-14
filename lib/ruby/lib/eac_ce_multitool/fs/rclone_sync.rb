# frozen_string_literal: true

module EacCeMultitool
  module Fs
    class RcloneSync
      acts_as_immutable
      immutable_accessor :extra, :source, :target, type: :common
      immutable_accessor :confirm, :delete, :mkdirp, :verbose, type: :boolean
      immutable_accessor :exclude, type: :array

      # @return [EacCeMultitool::Fs::RcloneSync::SyncResult, void]
      def perform
        target.mkdirp if mkdirp
        verbose? ? perform_system : perform_execute
      end

      # @param value [Object]
      # @return [EacCeMultitool::Fs::RcloneSync::Path, nil]
      def source_set_filter(value)
        value.if_present(nil) { |v| ::EacCeMultitool::Fs::RcloneSync::Path.new(v) }
      end

      # @param value [Object]
      # @return [EacCeMultitool::Fs::RcloneSync::Path, nil]
      def target_set_filter(value)
        source_set_filter(value)
      end

      protected

      # @return [EacCeMultitool::Fs::RcloneSync::SyncResult]
      def perform_execute
        result = rclone_command.execute
        return ::EacCeMultitool::Fs::RcloneSync::SyncResult.from_string(result.fetch(:stderr)) if
        result.fetch(:exit_code).zero?

        raise ::EacRubyUtils::Envs::ExecutionError,
              "execute! command failed: #{rclone_command}\n#{result.pretty_inspect}"
      end

      # @return [void]
      def perform_system
        rclone_command.system!
      end

      # @return [EacRubyUtils::Envs::Command]
      def rclone_command
        ::Cliutils::Executables.rclone.command.append(rclone_args)
      end

      require_sub __FILE__, require_mode: :kernel
        end
  end
end
