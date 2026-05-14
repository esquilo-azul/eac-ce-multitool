# frozen_string_literal: true


module EacCeMultitool
  module Fs
    class RsyncSync
      class RsyncResult
        enable_speaker
        attr_reader :files

        BEGIN_TEXTS = ['receiving incremental file list', 'sending incremental file list'].freeze

        def initialize(content)
          @phase = :begin
          @files = []
          content.each_line { |line| add_line(line) }
          @files.freeze
        end

        def count(directory, delete)
          files.count { |f| f.directory == directory && f.delete == delete }
        end

        def count_label(directory, delete, label)
          c = count(directory, delete)
          delete_color = delete ? :red : :green
          "#{label}: #{c}".colorize(c.positive? ? delete_color : :light_black)
        end

        def banner
          { 'Files' => false, 'Directory' => true }.each do |label, directory|
            puts "#{label}: ".cyan +
                 { new: false, removed: true }
                   .map { |c_label, delete| count_label(directory, delete, c_label) }
                     .join(' | ')
          end
        end

        private

        attr_accessor :phase

        def add_line(line)
          send("on_#{phase}_add_line", line.strip)
        end

        def on_begin_add_line(line)
          if BEGIN_TEXTS.include?(line)
            self.phase = :files
          else
            raise_line(line)
          end
        end

        def on_files_add_line(line)
          if line.present?
            @files << parse_file_line(line) if line != './'
          else
            self.phase = :footer
          end
        end

        def on_footer_add_line(line)
          # DO nothing
        end

        def raise_line(line)
          raise "Unexpected line (Text: |#{line}|, Phase: #{phase})"
        end

        def parse_file_line(line)
          delete = false
          path = line
          m = /\Adeleting (.+)\z/.match(line)
          if m
            delete = true
            path = m[1]
          end
          { path: path, directory: path.end_with?('/'), delete: delete }.to_struct
        end
      end
        end
  end
end
