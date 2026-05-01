#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class RemoveTrailingWhitespaces
  include ::EacRubyUtils::SimpleCache

  enable_speaker

  def initialize(file, options)
    @file = file
    @options = options
    run
  end

  private

  def run
    if File.exist?(@file)
      begin
        try_change
      rescue StandardError => e
        raise "#{@file}: #{e}"
      end
    else
      file_info('does not exist'.red)
    end
  end

  def try_change
    if new_content == content
      file_info('unchanged'.white)
    else
      write_new_content
      file_info('changed'.green)
    end
  end

  def write_new_content
    File.write(@file, new_content)
  end

  def new_content_uncached
    b = ''
    content.each_line do |line|
      b += "#{line.rstrip}\n"
    end
    "#{b.strip}\n".gsub("\t", '  ')
  end

  def content_uncached
    File.read(@file)
  end

  def file_info(status)
    return if @options.silent

    puts("#{@file.yellow}: #{status}")
  end
end

require 'optparse'
Options = Struct.new(:silent)

class Parser
  class << self
    def parse(options)
      args = Options.new(false)
      build_option_parser(args).parse!(options)
      args
    end

    private

    def build_option_parser(args)
      OptionParser.new do |opts|
        opts.banner = "Usage: #{__FILE__} [options]"
        opts.on('--silent', 'Não mostra mensagens') { args.silent = true }
        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit
        end
      end
    end
  end
end
options = Parser.parse ARGV

ARGV.each do |arg|
  RemoveTrailingWhitespaces.new(arg, options)
end
