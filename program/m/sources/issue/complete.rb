#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

require 'shellwords'

class CompleteIssueRunner
  enable_jobs_runner
  JOBS = %w[banner complete launcher done].freeze

  runner_with :confirmation, :help do
    desc 'Conclui demanda no Git.'
    arg_opt '-C', '--dir', 'Diretório base.'
    arg_opt '-a', '--complete-args', 'Parâmetros para "avm git issue complete".'
  end

  def run
    run_jobs
  end

  def banner
    infov 'Directory', dir
    infov 'Projects root', projects_root
    infov 'TRF1 projects root', trf1_dir
    infov 'Method', complete_method
    infov 'Launcher instance path', launcher_instance_path
    infov 'Complete args', complete_args
  end

  def complete
    if complete_command.system
      success 'Complete done'
    else
      fatal_error 'Complete unsuccessful'
    end
  end

  def done
    success('Ok!')
  end

  def launcher
    infov 'Launcher instance path', launcher_instance_path
    infom 'Launcher checking...'
    launcher_command(launcher_instance_path).system!
    run_confirm('Confirm launcher run?') { launcher_command('--pending', '--run').system! }
  end

  private

  def current_dir
    ENV.fetch('PWD')
  end

  def dir_uncached
    parsed.dir.if_present(current_dir).to_pathname.expand_path
  end

  def complete_method_uncached
    trf1_project? ? '/s/pd1-tools' : 'w/avm'
  end

  def complete_command
    ::Cliutils::Core.command(complete_method, 'source', '-C', dir, 'issue', *complete_args)
  end

  def projects_root_uncached
    ENV['PROJECTS_ROOT'].to_pathname.expand_path
  end

  # @return [Boolean]
  def trf1_project?
    dir.to_path.start_with?(trf1_dir.to_path)
  end

  # @return [Pathname]
  def trf1_dir
    ENV['TRF1_PROJECTS_ROOT'].to_pathname
  end

  def complete_args_uncached
    r = ['complete']
    r << '--yes' if parsed.yes?
    r += parsed.complete_args.if_present([]) do |v|
      ::Shellwords.split(v)
    end
    r
  end

  def launcher_command(*)
    ::Cliutils::Core.command('w/avm', 'launcher', 'publish', '--new', *)
  end

  def launcher_instance_path
    "/#{dir.basename}*"
  end

  def launcher_run_confirm?; end
end

CompleteIssueRunner.run
