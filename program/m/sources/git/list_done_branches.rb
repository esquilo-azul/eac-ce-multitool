#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class Runner < Cliutils::DocoptRunner
  enable_speaker
  runner_with :help do
    desc 'Remove branches de tarefas já concluídas'
    arg_opt '-f', '--force', 'When -r is used remove also not equal branches.'
    arg_opt '-r', '--remove', 'Remove done and equal branches.'
  end

  private

  def run
    ::Cliutils::Git::ListDoneBranches.new('.', parsed)
  end
end

Runner.run
