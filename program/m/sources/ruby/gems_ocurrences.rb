#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class GemsManager
  SELECTED_APPLICATIONS = [].freeze
  RUBY_STEREOTYPES = %w[EacRubyBase1 EacRubyBase0].freeze

  enable_simple_cache
  common_constructor :applications

  protected

  def fs_object_id
    'gems_manager'
  end

  def select_source?(source)
    applications.empty? || applications.include?(source.application_id)
  end

  def sources_uncached
    r = {}
    (sources_from_applications + sources_from_subs).each do |e|
      r[e.application.id] = e
    end
    r.values.map { |e| ::SourceExtension.new(e) }.sort.select { |f| select_source?(f) }
  end

  def sources_from_applications_uncached
    fs_cache.child('sources_from_applications').read_or_store_yaml do
      applications_from_registry.to_h { |e| [e.id, e.local_source_path] }
    end.map do |_k, v| # rubocop:disable Style/MultilineBlockChain
      ::Avm::EacRubyBase1::Sources::Base.new(v)
    end
  end

  def sources_from_subs_uncached
    fs_cache.child('sources_from_subs').read_or_store_yaml do
      sources_from_applications.flat_map(&:subs).to_h { |e| [e.application.id, e.path] }
    end.map do |_k, v| # rubocop:disable Style/MultilineBlockChain
      ::Avm::EacRubyBase1::Sources::Base.new(v)
    end
  end

  def applications_from_registry
    ::Avm::Registry.applications.available.select do |e|
      e.id
      e.local_source_path
      RUBY_STEREOTYPES.include?(e.stereotype.name)
    rescue ::StandardError => e
      puts e
      nil
    end.reject(&:blank?)
  end
end

class SourceExtension < SimpleDelegator
  enable_simple_cache
  compare_by :application_id

  protected

  def files_to_search_uncached
    (lib_files_to_search + spec_files_to_search).map do |e|
      ::SourceFile.new(self, e)
    end
  end

  def lib_files_to_search
    path.join('lib').join(gem_name.split('-').join('/')).glob('**/*.rb')
  end

  def spec_files_to_search
    path.join('spec').glob('**/*.rb') - [path.join('spec', 'spec_helper.rb')].sort
  end

  def system_grep
    ::Cliutils::Core.env.command('grep', '--recursive', 'require_sub', path.to_path).system
  end
end

class SourceFile
  enable_simple_cache
  common_constructor :source, :path

  REQUIRE_SUFFIXES = %w[aranha avm eac ehbrs].freeze

  def pending
    r = []
    r << "require[#{requires.join(', ')}]" if requires.any?
    r << 'require_sub' if require_subs.any?
    r
  end

  def relative_path
    path.relative_path_from(source.path)
  end

  def require_subs_uncached
    content.scan(/require_sub.+__FILE__\)?$/m)
  end

  def require_suffix?(require_path)
    REQUIRE_SUFFIXES.any? { |e| require_path.start_with?(e) }
  end

  def to_s
    relative_path.to_path
  end

  protected

  def content_uncached
    path.read
  end

  def requires_uncached
    content.scan(/require '([^']+)'/m).map(&:first).select { |e| require_suffix?(e) }
  end
end

class TheRunner
  enable_simple_cache
  runner_with :help do
    pos_arg :application, repeat: true, optional: true
  end

  # @return [void]
  def run
    manager.sources.map do |e|
      show_gem(e)
    end
  end

  protected

  def show_gem(source)
    infov source.application.id, source.path
    source.files_to_search.each do |file|
      infov "  * #{file}", file.pending.join(' | '.blue) if file.pending.any?
    end
  end

  def manager_uncached
    ::GemsManager.new(parsed.application)
  end
end

TheRunner.run
