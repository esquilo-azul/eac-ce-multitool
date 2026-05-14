# frozen_string_literal: true


module EacCeMultitool
  module Fs
    class RcloneSync
      class SyncResult < ::Aranha::Parsers::Base
        class Banner
          acts_as_instance_method
          enable_speaker
          common_constructor :owner

          def result
            ::EacCeMultitool::Fs::RcloneSync::SyncResult::Entry.lists.fs_type.each_value { |fs_type| print_fs_type(fs_type) }
          end

          protected

          def print_fs_type(fs_type)
            puts "#{fs_type}: ".cyan +
                 ::EacCeMultitool::Fs::RcloneSync::SyncResult::Entry.lists.operation.values
                   .map { |operation| operation_label(fs_type, operation) }
                   .join(' | ')
          end

          def count(fs_type, operation)
            owner.fs_entries.count { |e| e.fs_type == fs_type && e.operation == operation }
          end

          def operation_label(fs_type, operation)
            c = count(fs_type, operation)
            "#{operation}: #{c}".colorize(c.positive? ? :light : :light_black)
          end
        end
      end
        end
  end
end
