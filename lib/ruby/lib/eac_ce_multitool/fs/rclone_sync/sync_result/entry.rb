# frozen_string_literal: true


module EacCeMultitool
  module Fs
    class RcloneSync
      class SyncResult < ::Aranha::Parsers::Base
        class Entry
          class << self
            def assert(source)
              return assert(::JSON.parse(source)) if source.is_a?(::String)
              return new(source) if source.is_a?(::Hash)

              nyi "Source: #{source.to_debug}"
            end
          end

          enable_simple_cache
          enable_listable
          lists.add_symbol :fs_type, :directory, :file
          lists.add_symbol :operation, :change, :create, :move, :remove, :update_meta
          compare_by :fs_path, :operation

          OPERATION_MESSAGE_PATTERNS = {
            /\ACopied \(new\)\z/ => OPERATION_CREATE,
            /\ACopied \(replaced existing\)\z/ => OPERATION_CHANGE,
            /\ADeleted\z/ => OPERATION_REMOVE,
            /\AMoved / => OPERATION_MOVE,
            /\ARemoving directory\z/ => OPERATION_REMOVE,
            /\ARenamed from / => OPERATION_MOVE,
            /\AUpdated modification time in destination\z/ => OPERATION_UPDATE_META
          }.freeze

          common_constructor :source_data

          def data
            {
              # source: source_data,
              fs_type: fs_type,
              fs_path: fs_path,
              operation: operation
            }
          end

          # @return [Boolean]
          def fs_operation?
            fs_type.present? && operation.present?
          end

          def fs_path
            source_data['object']
          end

          # @return [Symbol]
          def fs_type
            source_data.if_key('objectType', nil) do |v|
              case v
              when '*local.Object' then FS_TYPE_FILE
              when 'string' then FS_TYPE_DIRECTORY
              when '*local.Fs' then nil
              else nyi "Unmapped object type: #{source_data}."
              end
            end
          end

          # @return [Symbol]
          def operation
            if source_data.key?('skipped')
              operation_by_skipped
            else
              operation_by_message
            end
          end

          # @return [Symbol]
          def operation_by_message
            message = source_data.fetch('msg')
            OPERATION_MESSAGE_PATTERNS.find { |pattern, _operation| pattern.match?(message) }
              .if_present(&:last) || raise("Unmapped pattern for message \"#{message}\"")
          end

          # @return [Symbol]
          def operation_by_skipped
            s = source_data['skipped']
            case s
            when 'copy' then OPERATION_CREATE
            when 'update modification time' then OPERATION_UPDATE_META
            when 'move' then OPERATION_MOVE
            when 'delete', 'remove directory' then OPERATION_REMOVE
            else nyi source_data
            end
          end
        end
      end
        end
  end
end
