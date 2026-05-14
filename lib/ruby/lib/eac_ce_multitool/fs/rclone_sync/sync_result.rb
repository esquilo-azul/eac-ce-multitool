# frozen_string_literal: true


module EacCeMultitool
  module Fs
    class RcloneSync
      class SyncResult < ::Aranha::Parsers::Base
        # @return [Hash]
        def data
          fs_entries.sort.map(&:data)
        end

        # @return [Enumerable<EacCeMultitool::Fs::RcloneSync::SyncResult::Entry>]
        def entries
          content.each_line.map { |line| ::EacCeMultitool::Fs::RcloneSync::SyncResult::Entry.assert(line) }
        end

        # @return [Enumerable<EacCeMultitool::Fs::RcloneSync::SyncResult::Entry>]
        def fs_entries
          entries.select(&:fs_operation?)
        end

        require_sub __FILE__, require_mode: :kernel
      end
        end
  end
end
