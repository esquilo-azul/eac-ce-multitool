#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class LineProcessor
  LINE_STRUCT = ::Struct.new(:left, :right)
  LINE_PATTERN = /\A(.+)(?:\#\s*rubocop:disable\s*(.+))?\z/

  enable_simple_cache
  common_constructor :line, :offenses

  def result
    r = line_left
    r += " # rubocop:disable #{all_cops.join(',')}" if all_cops.any?
    "#{r}\n"
  end

  private

  # @return [Array<String>]
  def all_cops_uncached
    (current_cops + offenses_cops).uniq.sort
  end

  # @return [Array<String>]
  def current_cops
    parsed_line[1].if_present([]) { |s| s.split(',').map(&:strip).select(&:present) }
  end

  # @return [Array<String>]
  def offenses_cops
    offenses.map(&:cop_name)
  end

  def line_left
    parsed_line[0]
  end

  # @return [LINE_STRUCT]
  def parsed_line_uncached
    m = LINE_PATTERN.match(line)
    if m
      LINE_STRUCT.new(m[1].rstrip, m[2].rstrip)
    else
      LINE_STRUCT.new(line.rstrip, nil)
    end
  end
end

class Offense
  class << self
    def by_data(data)
      new(data)
    end
  end

  common_constructor :data

  def cop_name
    data.fetch('cop_name')
  end

  # @return [Integer]
  def line_index
    line_number - 1
  end

  # @return [Integer]
  def line_number
    data.fetch('location').fetch('line')
  end
end

class FileOffenses
  class << self
    # @param data [Hash]
    # @return [FileOffenses]
    def by_data(data)
      new(data.fetch('path'), data.fetch('offenses').map { |odata| ::Offense.by_data(odata) })
    end
  end

  common_constructor :path, :offenses do
    self.path = path.to_pathname
  end

  def disable_rubocop
    path.write(disable_rubocop_content)
  end

  # @return [Boolean]
  def offenses?
    offenses.any?
  end

  private

  # @return [String]
  def disable_rubocop_content
    path.read.each_line.with_index.map do |line, index|
      ::LineProcessor.new(line, line_offenses(index)).result
    end.join
  end

  # @param index [Integer]
  # @return [Enumerable<Offense>]
  def line_offenses(index)
    offenses.select { |o| o.line_index == index }
  end
end

class FilesOffenses
  enable_simple_cache
  common_constructor :source

  def disable_rubocop
    files.each(&:disable_rubocop)
  end

  private

  # @return [Enumerable<FileOffenses>]
  def files_uncached
    rubocop_data.fetch('files').map { |data| ::FileOffenses.by_data(data) }.select(&:offenses?)
  end

  # @return [Hash]
  def rubocop_data
    JSON.parse(
      source.bundle('exec', 'rubocop', '--ignore-parent-exclusion', '--format', 'json').execute
      .fetch(:stdout)
    )
  end
end

class RubocopCop
  enable_speaker
  common_constructor :runner, :name, :data
  delegate :config_data, :config_path, :source, to: :runner

  # @return [Boolean]
  def cop?
    name.include?('/')
  end

  # @return [Boolean]
  def exclude?
    data.key?('Exclude')
  end

  # @return [Boolean]
  def excluded?
    runner.excludes.include?(name)
  end

  # @return [Boolean]
  def match_filter?
    runner.filter.match?(name)
  end

  # @return [Boolean]
  def selected?
    cop? && exclude? && match_filter? && !excluded?
  end

  # @return [String]
  def to_s
    name
  end

  # @return [Boolean]
  def perform
    infov 'Cop', name
    r = nil
    source.scm.commit_if_change(commit_message) do
      remove_cop_from_config
      r = run_rubocop || disable_rubocop
    end
    r
  end

  def commit_message
    ".rubocop.yml##{name}: remove."
  end

  # @return [Boolean]
  def disable_rubocop
    ::FilesOffenses.new(source).disable_rubocop
    run_rubocop
  end

  def remove_cop_from_config
    d = config_data
    d.delete(name)
    config_path.write(::YAML.dump(d))
  end

  # @return [Boolean]
  def run_rubocop
    source.bundle('exec', 'rubocop', *run_rubocop_args).envvar_gemfile.system
  end

  def run_rubocop_args
    r = ['--ignore-parent-exclusion']
    if runner.autocorrect_all?
      r << '--autocorrect-all'
    elsif runner.autocorrect?
      r << '--autocorrect'
    end
    r
  end
end

class TheRunner
  runner_with :help do
    bool_opt '-a', '--autocorrect'
    bool_opt '-A', '--autocorrect-all'
    arg_opt '-f', '--filter', default: '.+'
    arg_opt '-C', '--source', default: '.'
    arg_opt '-e', '--exclude', repeat: true
  end
  delegate :autocorrect?, :autocorrect_all?, to: :parsed

  def run
    infov 'Source path', source_path
    infov 'Source', source
    infov 'Cops with exclude', cops_with_exclude.count
    infov 'Filter', filter
    cops_with_exclude.each do |cwe|
      break unless cwe.perform
    end
  end

  # @return [Hash]
  def config_data
    ::YAML.load_file(config_path)
  end

  # @return [Pathname]
  def config_path
    source.path.join('.rubocop.yml')
  end

  # @return [Enumerable<String>]
  def excludes
    parsed.exclude
  end

  # @return [Regexp]
  def filter
    ::Regexp.new(parsed.filter)
  end

  # @return [Pathname]
  def source_path
    parsed.source.to_pathname.expand_path
  end

  private

  # @return [Array<String>]
  def cops_with_exclude_uncached
    config_data.map { |k, v| ::RubocopCop.new(self, k, v) }.select(&:selected?)
  end

  # @return [Avm::Sources::Base]
  def source_uncached
    ::Avm::Registry.sources.detect(source_path)
  end
end

TheRunner.run
