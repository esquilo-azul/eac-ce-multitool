#!/usr/bin/env ruby
# frozen_string_literal: true

require ENV.fetch('RUBY_TO_REQUIRE')

class OrganizationBuilder
  def add_application(application)
    organization(application.organization).add_application(application)

    self
  end

  def result
    organizations.values
  end

  protected

  def organization(id)
    organizations[id] ||= ::OrganizationWrapper.new(id) unless organizations.key?(id)

    organizations.fetch(id)
  end

  def organizations
    @organizations ||= {}
  end
end

class OrganizationWrapper
  enable_speaker
  common_constructor :id

  def add_application(application)
    applications << ::ApplicationWrapper.new(application)
  end

  def show
    infov id, applications.count
    applications.sort_by { |a| [a.id] }.each(&:show)
  end

  def applications
    @applications ||= []
  end
end

class ApplicationWrapper < SimpleDelegator
  enable_speaker

  def show
    infov id, user_local_source_path
  end
end

class TheRunner
  runner_with :help do
    arg_opt '-o', '--organization', repeat: true
  end

  # @return [Array<String>]
  def selected_organizations
    parsed.organization
  end

  def run
    show_applications
  end

  protected

  def organizations_uncached
    ::Avm::Registry.applications.available
      .inject(::OrganizationBuilder.new) { |a, e| a.add_application(e) }.result
      .select { |o| select_organization?(o) }
  end

  def select_organization?(organization)
    return true if selected_organizations.empty?

    selected_organizations.include?(organization.id)
  end

  def show_applications
    infov 'Organizations', organizations.count
    organizations.each(&:show)
  end

  def show_sources
    infov 'Sources', sources.count
    sources.each do |source|
      infov '  * ', source
    end
  end

  def sources_uncached
    applications.map(&:user_local_source_path).compact
  end
end

TheRunner.run
