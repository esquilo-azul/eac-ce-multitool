#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class Attribute
  common_constructor :name

  def declaration
    <<~CODE
      /**
       *
       * @var type
       */
      private #{variable};
    CODE
  end

  def variable
    "$#{name}"
  end
end

class TheRunner
  runner_with :help, :output do
    pos_arg :attribute, repeat: true
  end

  def run
    run_output
  end

  def output_content
    [attributes_declarations, constructor].map { |s| "#{s}\n" }.join
  end

  def attributes
    parsed.attribute.map { |name| ::Attribute.new(name) }
  end

  def attributes_declarations
    attributes.map(&:declaration).join("\n")
  end

  def constructor
    (
      ["public function __construct(#{attributes.map(&:variable).join(', ')}) {"] +
        attributes.map { |a| "$this->#{a.name} = #{a.variable};" } + ['}']
    ).join("\n")
  end
end

TheRunner.run
