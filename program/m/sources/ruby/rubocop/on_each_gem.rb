#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class Runner
  enable_simple_cache
  enable_speaker

  runner_with :help do
    pos_arg :dirs, repeat: true
  end

  def run
    start_banner
    bundle_all_gems
    gems.each do |gem|
      infov 'Gem', gem.name
      ::EacRubyUtils::Speaker.context.on(::EacCli::Speaker.new(err_line_prefix: '  ')) do
        gem_rubocop(gem)
      end
    end
  end

  private

  def start_banner
    infov 'Gems found', gems.count
  end

  def bundle_all_gems
    infom 'Bundling all gems...'
    gems.each do |gem|
      next unless gem.gemfile_path.exist?

      infov 'Bundle install', gem
      gem.bundle.execute!
    end
  end

  def gems_uncached
    parsed.dirs.map { |dir| ::Avm::EacRubyBase1::Sources::Base.new(dir) }
  end

  def gem_rubocop(gem)
    infov '* Path', gem.root
    ::Cliutils::Core.command('m/sources/ruby/rubocop/run', '--ignore-parent-exclusion',
                             '--auto-correct')
      .chdir(gem.root).system!
  end

  def list_option(option)
    parsed.fetch(option).to_s.split(',').map(&:strip).compact_blank
  end
end

Runner.run
