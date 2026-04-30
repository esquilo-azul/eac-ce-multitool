#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')
require 'memoized'

module PageExtender
  attr_accessor :runner

  # @return [void]
  def perform
    runner.infom '--------'
    %w[sub_path page_title target_path].each do |e|
      runner.infov e, send(e)
    end
    return unless runner.write?

    write
    runner.success 'Page content writed'
  end

  # @return [String]
  def page_title
    ::Avm::EacRedmineBase0::Instances::RestApi::WikiPage.instance_method(:title).bind(self).call
  end

  # @return [Pathname]
  def sub_path
    (parent_title.if_present([]) do |v|
      [v]
    end + [page_title]).map(&:parameterize).join('/').to_pathname
  end

  # @return [Pathname]
  def target_path
    runner.target_directory.join("#{sub_path}.textile")
  end

  # @return [void]
  def write
    ::FileUtils.mkdir_p(target_path.dirname)
    target_path.write(read)
  end
end

class TheRunner
  include Memoized

  REQUIRED_INSTANCE_CLASS = Avm::EacRedmineBase0::Instances::Base

  runner_with :help do
    arg_opt '-C', '--target-directory', default: './wiki-pages'
    bool_opt '-w', '--write'
    pos_arg :instance_id
    pos_arg :project_id
  end

  delegate :write?, to: :parsed

  def run
    start_banner
    target_directory.clear
    pages.each(&:perform)
    success('Done')
  end

  memoize def pages
    redmine_project.wiki_pages.map do |e|
      e.singleton_class.include(PageExtender)
      e.runner = self
      e
    end.sort_by { |e| [e.sub_path] } # rubocop:disable Style/MultilineBlockChain
  end

  memoize def redmine_instance
    r = Avm::Registry.instances.detect(redmine_instance_id)
    unless r.is_a?(REQUIRED_INSTANCE_CLASS)
      fatal_error "\"#{redmine_instance_id}\" is not a #{REQUIRED_INSTANCE_CLASS.stereotype_name}" \
                  ", but a #{r.class.stereotype_name}"
    end
    r
  end

  # @return [String]
  def redmine_instance_id
    parsed.instance_id
  end

  memoize def redmine_project
    redmine_instance.rest_api.root_entity.project(parsed.project_id)
  end

  # @return [void]
  def start_banner
    infov 'Target directory', target_directory
    infov 'Redmine instance ID', redmine_instance_id
    infov 'Project ID', redmine_project.id
    infov 'Pages', pages.count
  end

  # @return [EacRubyUtils::Fs::ClearableDirectory]
  memoize def target_directory
    EacRubyUtils::Fs::ClearableDirectory.new(parsed.target_directory)
  end
end

TheRunner.run
