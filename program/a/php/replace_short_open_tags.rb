#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class TheRunner
  runner_with :help, :filesystem_traverser

  def run
    @files = []
    run_filesystem_traverser
    infov 'Command', ::Shellwords.join(aux_replace_args)
    ::Cliutils::Core.env.command(*aux_replace_args).system!
  end

  def aux_replace_args
    ['php', '-d', 'short_open_tag=On',
     ::Cliutils::Core::Paths.program_path('a/php/replace_short_open_tags_aux')] +
      @files
  end

  def traverser_check_file(file)
    return unless file.extname == '.php'

    @files << file
  end
end

TheRunner.run
