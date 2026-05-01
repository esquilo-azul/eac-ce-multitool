#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')
require 'clipboard'

require 'redcloth'

class TheRunner
  runner_with :help, :input do
    desc 'Extrai IDs de issues Redmine.'
    pos_arg :file, optional: true
  end

  private

  def run
    infov 'File', parsed.file.if_present('-')
    out output_content
  end

  def output_content
    issues.map { |s| "##{s}" }.join(', ') + "\n" # rubocop:disable Style/StringConcatenation
  end

  def issues_uncached
    input_content.scan(/\#\d+/).map { |s| s.gsub(/\A\#/, '').to_i }
  end
end

TheRunner.run
