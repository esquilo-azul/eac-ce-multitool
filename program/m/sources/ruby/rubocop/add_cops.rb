#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class RubocopConfig
  attr_reader :data

  common_constructor :path do
    self.path = path.to_pathname
    read
  end

  def add_cop(cop)
    data[cop] = { 'Enabled' => true }

    self
  end

  def cop?(cop)
    data.key?(cop)
  end

  def formatted_data
    kk = %w[require AllCops]
    (kk.map { |k| [k, data.fetch(k)] } + data.except(*kk).sort).to_h
  end

  def read
    self.data = ::YAML.load_file(path)
  end

  def write
    path.write(::YAML.dump(formatted_data))
  end

  private

  attr_writer :data
end

class Cop
  enable_simple_cache
  enable_speaker
  common_constructor :runner, :cop

  def perform
    infov 'Cop', cop
    if rubocop_config.cop?(cop)
      infom '  Cop already exist'
    else
      runner.rubocop_config.add_cop(cop).write
    end
  end
end

class TheRunner
  COP_LINE_PARSER = %r{(\S+/\S+)}.to_parser do |m|
    m[1]
  end

  runner_with :help do
    pos_arg :rubocop_config_path
    pos_arg :cops_file
  end

  def run
    rubocop_config.write
  end

  def run1
    infov 'Cops found', cops.count
    cops.each(&:perform)
  end

  private

  def cops_uncached
    parsed.cops_file.to_pathname.read.each_line.map { |line| parse_cop_line(line) }
      .map { |cop| ::Cop.new(self, cop) }[0..0]
  end

  def parse_cop_line(line)
    COP_LINE_PARSER.parse!(line)
  end

  def rubocop_config_uncached
    ::RubocopConfig.new(parsed.rubocop_config_path)
  end
end

TheRunner.run
