#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class Sub
  enable_speaker
  common_constructor :owner, :path

  def perform
    infov subpath, result
  end

  def result
    gitrepo_file.file? ? 'exist'.green : 'not exist'.red
  end

  def gitrepo_file
    path.join('.gitrepo')
  end

  def subpath
    path.basename
  end
end

class Runner
  runner_with :help do
    desc 'Verifica a presença de arquivos .gitrepo nos diretórios imediatamente sob <subs-root>.'
    pos_arg :subs_root
  end

  def run
    subs.each(&:perform)
  end

  private

  def subs_uncached
    parsed.subs_root.to_pathname.children.sort.map { |path| ::Sub.new(self, path) }
  end
end

Runner.run
