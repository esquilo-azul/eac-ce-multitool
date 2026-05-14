#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class TheRunner
  REPLACEMENTS = {
    'escaped_double_quotes' => {
      '\\"' => '"'
    },
    'new_line_character' => {
      '\\n' => ''
    },
    'concatenation' => {
      /"\s+\./ => '<?=',
      /\.\s+"/ => '?>'
    }
  }.freeze

  runner_with :help, :input, :output

  def run
    run_output
  end

  def output_content
    # .gsub(/(\$[a-z_][a-z_0-9]*)/i, '<?= \\1 ?>')
    replacements.inject(input_content) { |a, e| a.gsub(e[0], e[1]) }
  end

  def replacements
    REPLACEMENTS.values.inject({}) { |a, e| a.merge(e) }
  end
end

TheRunner.run
