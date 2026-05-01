#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class RubocopCop
  common_constructor :name
  compare_by :name
  TAB = '  '

  def add_file(file)
    files_set << file
  end

  def data_key
    name
  end

  def data_value
    { 'Exclude' => files_set.sort.map { |file| file.path.to_path } }
  end

  private

  def files_set
    @files_set ||= ::Set.new
  end
end

class RubocopCopSet
  def add_file(file)
    file.cop_names.each do |cop_name|
      add_file_cop(cop_name, file)
    end
  end

  def cops
    cops_hash.values.sort
  end

  def data
    cops.inject({}) { |a, e| a.merge(e.data_key => e.data_value) }
  end

  private

  def add_file_cop(cop_name, file)
    cops_hash[cop_name] ||= ::RubocopCop.new(cop_name)
    cops_hash[cop_name].add_file(file)
  end

  def cops_hash
    @cops_hash ||= {}
  end
end

class RubocopFile
  common_constructor :data
  compare_by :path

  def path
    data.fetch('path').to_pathname
  end

  def cop_names
    data.fetch('offenses').map { |d| d.fetch('cop_name') }
  end

  def offenses?
    data.fetch('offenses').any?
  end
end

class TheRunner
  runner_with :help, :output
  RUBOCOP_OK_CODES = [0, 256].freeze

  def run
    infov 'Files', files.count
    infov 'Cops', cops.count
    run_output
  end

  def output_content
    ::YAML.dump(cop_set.data)
  end

  private

  def cops
    cop_set.cops
  end

  def cop_set_uncached
    r = ::RubocopCopSet.new
    files.each { |file| r.add_file(file) }
    r
  end

  def files_uncached
    rubocop_data.fetch('files').map { |file_data| ::RubocopFile.new(file_data) }.select(&:offenses?)
  end

  def rubocop_data
    ::JSON.parse(rubocop_output)
  end

  def rubocop_output
    r = rubocop_command.execute
    if RUBOCOP_OK_CODES.include?(r.fetch(:exit_code)) && r.fetch(:stdout).present?
      return r.fetch(:stdout)
    end

    raise r.pretty_inspect
  end

  def rubocop_command
    ::Cliutils::Core.command('w/avm', 'source', 'bundle', 'exec', 'rubocop', '--',
                             '--ignore-parent-exclusion', '--format', 'json')
  end
end

TheRunner.run
