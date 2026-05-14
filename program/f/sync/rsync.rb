#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class SyncRunner
  runner_with :confirmation, :help do
    desc 'Sincroniza diretórios.'
    bool_opt '-d', '--delete', 'Remove conteúdo no destino.'
    bool_opt '-i', '--invert', 'Inverte <source-uri> e <target-uri>.'
    bool_opt '-r', '--run', 'Executa não-dry-run.'
    bool_opt '-v', '--verbose', '"Verbose".'
    bool_opt '-f', '--fat', 'Rsync parametrizado para FAT.'
    bool_opt '-F', '--fuse', 'Rsync parametrizado para FUSE.'
    arg_opt '-e', '--exclude', 'Opção --exclude do rsync.'
    bool_opt '-t', '--target-mkdirp', 'Cria diretório alvo se ainda não existir.'
    arg_opt '-E', '--extra', 'Opções para o comando "rsync"'
    pos_arg 'source-uri'
    pos_arg 'target-uri'
  end

  DIRECTORY_SYNC_OPTIONS = {
    delete: :delete, extra: :extra, fat: :fat, fuse: :fuse, mkdirp: :target_mkdirp
  }.freeze

  def run
    start_banner
    return unless run_sync?

    parsed.verbose? ? run_verbose : run_no_verbose
  end

  def run_verbose
    sync.system!(run?)
  end

  def run_no_verbose
    sync.execute!(run?).banner
  end

  def source_uri
    parsed.invert? ? parsed.target_uri : parsed.source_uri
  end

  def target_uri
    parsed.invert? ? parsed.source_uri : parsed.target_uri
  end

  private

  def run_sync?
    dry_run? || parsed.yes? || confirm?
  end

  def dry_run?
    !run?
  end

  def run?
    parsed.run?
  end

  def start_banner
    infov 'Source', sync.source
    infov 'Target', sync.target
    infov 'Dry run?', dry_run?
  end

  def sync_uncached
    ::EacCeMultitool::Fs::RsyncSync.new(
      source_uri, target_uri,
      { exclude: excludes }.merge(DIRECTORY_SYNC_OPTIONS.transform_values { |v| parsed.fetch(v) })
    )
  end

  def excludes
    parsed.exclude.to_s.split(',')
  end
end

SyncRunner.run
