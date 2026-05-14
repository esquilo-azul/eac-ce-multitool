#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class TheRunner
  runner_with :confirmation, :help do
    desc 'Sincroniza diretórios.'
    bool_opt '-d', '--delete', 'Remove conteúdo no destino.'
    bool_opt '-i', '--invert', 'Inverte <source-uri> e <target-uri>.'
    bool_opt '-r', '--run', 'Executa não-dry-run.'
    bool_opt '-v', '--verbose', '"Verbose".'
    arg_opt '-e', '--exclude', 'Opção --exclude do rclone.'
    bool_opt '-t', '--target-mkdirp', 'Cria diretório alvo se ainda não existir.'
    arg_opt '-E', '--extra', 'Opções extras para o comando "rclone"'
    pos_arg 'source-uri'
    pos_arg 'target-uri'
  end

  DIRECTORY_SYNC_OPTIONS = {
    delete: :delete, extra: :extra, mkdirp: :target_mkdirp
  }.freeze

  def run
    start_banner
    return unless run_sync?

    sync.perform.if_present(&:banner)
  end

  def source_uri
    parsed.invert? ? parsed.target_uri : parsed.source_uri
  end

  def target_uri
    parsed.invert? ? parsed.source_uri : parsed.target_uri
  end

  protected

  def dry_run?
    !run?
  end

  def excludes
    parsed.exclude.to_s.split(',')
  end

  def run?
    parsed.run?
  end

  def run_sync?
    dry_run? || parsed.yes? || confirm?
  end

  def start_banner
    infov 'Source', sync.source
    infov 'Target', sync.target
    infov 'Dry run?', dry_run?
  end

  def sync_uncached # rubocop:disable Metrics/AbcSize
    ::EacCeMultitool::Fs::RcloneSync.new.source(source_uri).target(target_uri).excludes(excludes)
      .confirm(run?).delete(parsed.delete?).extra(parsed.extra).verbose(parsed.verbose?)
  end
end

TheRunner.run
