#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class FastExportFile
  common_constructor :file

  def on_filtered_file
    ::EacRubyUtils::Fs::Temp.on_file do |temp_file|
      temp_file.write(filtered_content)
      yield(temp_file)
    end
  end

  def filtered_content
    file.read.each_line.map(&:rstrip).map { |line| filter_line(line) }
      .reject { |line| line == false }
      .map { |line| "#{line}\n" }.join
  end

  def filter_line(line)
    return false if line.start_with?('data')
    return false if line.start_with?('original-oid')

    line
  end
end

class FastExportComparison
  common_constructor :original, :filtered do
    self.original = ::FastExportFile.new(original)
    self.filtered = ::FastExportFile.new(filtered)
  end

  def show_changes
    original.on_filtered_file do |original_file|
      filtered.on_filtered_file do |filtered_file|
        ::EacRubyUtils::Envs.local.command('diff', '--color', original_file, filtered_file).system
      end
    end
  end
end

class TheRunner
  runner_with :help, :confirmation do
    desc 'Renomeia mensagens de commit do Core.'
    arg_opt '-C', '--path', default: '.'
    arg_opt '-e', '--expression', repeat: true
    arg_opt '-r', '--revision-range', default: 'origin/master..HEAD'
  end

  def expressions_content
    parsed.expression.map { |e| "#{e}\n" }.join
  end

  def run
    on_expressions_file do
      command(true).system!
      show_changes
      command(false).system if confirm?
    end
  end

  def on_expressions_file
    ::EacRubyUtils::Fs::Temp.on_file do |file|
      self.expressions_file = file
      expressions_file.write(expressions_content)
      yield
    end
  end

  delegate :show_changes, to: :comparison

  private

  attr_accessor :expressions_file

  def comparison_uncached
    ::FastExportComparison.new(
      original_file, filtered_file
    )
  end

  def git_uncached
    ::EacGit::Local.find(path)
  end

  def command(dry_run)
    args = ['filter-repo', '--replace-message', expressions_file, '--refs', 'origin/master..HEAD',
            '--force']
    args << '--dry-run' if dry_run
    git.command(*args)
  end

  def path
    parsed.path.to_pathname.expand_path
  end

  def original_file
    git.root_path.join('.git/filter-repo/fast-export.original')
  end

  def filtered_file
    git.root_path.join('.git/filter-repo/fast-export.filtered')
  end
end

TheRunner.run
