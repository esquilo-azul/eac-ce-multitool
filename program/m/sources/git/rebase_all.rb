#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class RebaseBranch
  enable_speaker

  def initialize(git, branch, target)
    @git = git
    @branch = branch.to_s
    @target = target.to_s
    run
  end

  private

  def run
    start_banner
    checkout
    infov(' * Rebase?', rebase)
  end

  def start_banner
    infov('Branch', @branch)
  end

  def checkout
    @git.execute!('checkout', @branch)
  end

  def rebase
    @git.execute!('rebase', @target)
    'Ok'.green
  rescue StandardError
    @git.execute!('rebase', '--abort')
    'Not ok'.red
  end
end

class Runner < Cliutils::DocoptRunner
  enable_speaker

  DOC = <<~DOCOPT
    Remove branches de tarefas já concluídas

    Usage:
      __PROGRAM__ [options]
      __PROGRAM__ -h | --help

    Options:
      -h --help             Show this screen.
      -a --all              Executa em todos os branches e não somente os associados a issues.

  DOCOPT

  private

  def run
    @git = ::Avm::Git::Launcher::Base.new('.')
    issue_branches.each do |b|
      RebaseBranch.new(@git, b, 'origin/master')
    end
  end

  def issue_branches
    r = @git.git.branches.local.reject { |b| b.name.include?('HEAD') }
    r = r.select { |b| b.name.start_with?('issue_') } unless options['--all']
    r
  end
end

Runner.run
