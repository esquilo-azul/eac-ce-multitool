#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class BranchCheck
  enable_speaker
  enable_simple_cache
  common_constructor(:git, :path, :options) { run }

  def name
    parse_path.fetch(:name)
  end

  def remote
    parse_path.fetch(:remote)
  end

  private

  def run
    return unless showable?

    banner
    clear if options.fetch(:confirm)
  end

  def banner
    infov('Path', path)
    infov('  * Name', name)
    infov('  * Remote', remote)
    infov('  * Revision', revision)
    infov('  * Follow master?', master_follow?)
    infov('  * Tag revision', tag_revision)
  end

  def parse_path_uncached
    m = %r{\Aremotes/([^/]+)/(.+)\z}.match(path)
    if m
      { remote: m[1], name: m[2] }
    else
      { remote: nil, name: path }
    end
  end

  def clear
    return unless cleanable?

    warn "Removing #{path}..."
    if remote.present?
      git.command('push', remote, ":refs/heads/#{name}").system!
    else
      git.command('branch', '-d', path).system!
    end
  end

  def showable?
    options.fetch(:verbose) || cleanable?
  end

  def revision_uncached
    git.rev_parse(path)
  end

  def cleanable?
    master_follow? || completed?
  end

  def completed?
    tag_revision.present?
  end

  def master_follow?
    git.descendant?('origin/master', revision)
  end

  def tag_revision
    git.rev_parse("refs/tags/#{name}")
  end
end

class Runner < Cliutils::DocoptRunner
  include ::EacCli::DefaultRunner

  BRANCH_REF_PREFIX = 'refs/heads/'
  SKIP_BRANCHES = %w[remotes/origin/master].freeze

  runner_definition do
    desc 'Limpa branches.'
    arg_opt '-s', '--skip', 'Skip branches.'
    bool_opt '-c', '--confirm', 'Remove branches.'
    bool_opt '-v', '--verbose', 'Verbose mode.'
    pos_arg 'branch', repeat: true, optional: true
  end

  def run
    branches.each do |path|
      BranchCheck.new(git, path, branch_options) unless skip_branch?(path)
    end
  end

  private

  def git_uncached
    ::EacGit::Local.new('.')
  end

  def branch_options
    { confirm: options['--confirm'], verbose: options['--verbose'] }
  end

  def branches
    return options['<branch>'] if options['<branch>'].any?

    git.command('for-each-ref', '--format', '%(refname)', BRANCH_REF_PREFIX).execute!.split("\n")
      .map { |b| b.gsub(/\A#{::Regexp.quote(BRANCH_REF_PREFIX)}/) }
  end

  def skip_branch?(path)
    skip_branches.include?(path)
  end

  def skip_branches_uncached
    SKIP_BRANCHES + options['--skip'].to_s.split(',').map(&:strip).compact_blank
  end
end

Runner.run
