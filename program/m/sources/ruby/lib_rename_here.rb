#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class TheRunner
  runner_with :help do
    pos_arg :from
    pos_arg :to
    pos_arg :other_args, optional: true, repeat: true
  end
  delegate :from, :other_args, :to, to: :parsed

  # @return [void]
  def run
    rename_command.system!
  end

  private

  # @return [EacRubyUtils::Envs::Command]
  def rename_command
    ::Cliutils::Core.command('s/eac-tools', 'eac-ruby-base1', 'lib-rename', '--recursive', '--from',
                             from, '--to', to, '.', *other_args)
  end
end

TheRunner.run
