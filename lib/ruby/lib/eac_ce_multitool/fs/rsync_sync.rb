# frozen_string_literal: true


module EacCeMultitool
  module Fs
    class RsyncSync
      require_sub __FILE__
      enable_simple_cache

      attr_reader :source, :target
      attr_accessor :delete, :exclude, :extra, :fat, :fuse, :mkdirp

      def initialize(source, target, options = {})
        @source = ::EacCeMultitool::Fs::RsyncSync::Path.new(source)
        @target = ::EacCeMultitool::Fs::RsyncSync::Path.new(target)
        options.each { |key, value| send("#{key}=", value) }
      end

      def execute!(confirm)
        ::EacCeMultitool::Fs::RsyncSync::RsyncResult.new(run('execute!', confirm))
      end

      def system!(confirm)
        run('system!', confirm)
      end

      private

      def run(method, confirm)
        target.mkdirp if mkdirp
        rsync_command(confirm).send(method)
      end

      def rsync_command(confirm)
        ::Cliutils::Executables.rsync.command.append(rsync_args(confirm))
      end

      def excludes
        return [] if exclude.blank?
        return exclude if exclude.is_a?(::Enumerable)

        [exclude]
      end

      def archive_args
        return [] if fuse

        ['--archive']
      end

      def delete_args
        delete ? ['--delete'] : []
      end

      def excludes_args
        excludes.flat_map { |e| ['--exclude', e] }
      end

      def extra_args
        return [] if extra.blank?

        extra.is_a?(::Enumerable) ? extra.to_a : ::Shellwords.split(extra.to_s)
      end

      def fat_args
        return [] unless fat

        ['--modify-window=1', '--copy-links']
      end

      def fuse_args
        return [] unless fuse

        %w[--recursive]
      end

      def rsync_args(confirm)
        %w[-vzh] + extra_args +
          %w[archive delete excludes extra fat fuse].flat_map { |opt| send("#{opt}_args") } +
          (confirm ? [] : ['--dry-run']) +
          source.to_rsync_args + target.to_rsync_args
      end
        end
  end
end
