#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class Runner
  runner_with :help do
    desc 'Run a code in a Rails application.'
    bool_opt '-i', 'Read code fron STDIN.'
    arg_opt '-C', '--path', 'Diretório de execução.'
    bool_opt '-v', '--verbose', 'Mostra o código.'
    pos_arg :code, optional: true
  end

  private

  def run
    if parsed.verbose?
      puts '==============================='
      puts ::File.read(code_file_path)
      puts '==============================='
    end
    Init.on_clear_bundle_gemfile { command.system! }
  end

  def code
    if parsed.i?
      $stdin.read
    elsif parsed.code.present
      parsed.code
    else
      fatal_error 'No code informed (Use -i or <code>)'
    end
  end

  def command
    r = ::EacRubyUtils::Envs.local.command('bin/rails', 'runner', code_file_path)
    r = r.chdir(parsed.path) if parsed.path.present?
    r
  end

  def code_file_path_uncached
    tempfile = Tempfile.new(['rails_code', '.rb'])
    tempfile.write(code)
    tempfile.close
    tempfile.path
  end
end

Runner.run
