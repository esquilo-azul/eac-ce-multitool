#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class TheRunner
  TRANSFORMATIONS = %w[dasherize camelize variableize underscore].freeze

  runner_with :help, :output do
    arg_opt '-t', '--transformation', repeat: true
    pos_arg :terms, repeat: true
  end

  def help_extra_text
    "Transformations:\n#{TRANSFORMATIONS.map { |t| "  * #{t}\n" }.join}"
  end

  def run
    infov 'Transformations', transformations
    run_output
  end

  def output_content
    terms.map { |term| "#{transform_term(term)}\n" }.join
  end

  def transform_term(term)
    transformations.inject(term) { |a, e| a.send(e) }
  end

  def transformations
    r = parsed.transformation
    r.each do |transformation|
      next if TRANSFORMATIONS.include?(transformation)

      raise "Transformation \"#{transformation}\" not available " \
            "(List: #{TRANSFORMATIONS.join(', ')}"
    end
    r
  end

  delegate :terms, to: :parsed
end

TheRunner.run
