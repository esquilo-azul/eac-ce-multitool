#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class Runner
  runner_with :help do
    desc 'Verifica um commit contra a AVM.'
    pos_arg :repository
    pos_arg :reference
  end

  def run
    check = ::Cliutils::Avm::Git::CommitCheck.new(git, parsed.reference)
    check.out_console
  end

  private

  def git_uncached
    ::Avm::Git::Launcher::Base.new(parsed.repository)
  end
end

Runner.run
