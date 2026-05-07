# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'eac_ce_multitool/version'

Gem::Specification.new do |s|
  s.name        = 'eac_ce_multitool'
  s.version     = EacCeMultitool::VERSION
  s.authors     = ['Put here the authors']
  s.summary     = 'Put here de description.'

  s.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH)
              .reject { |f| ['.', '..'].include?(File.basename(f)) }
  s.required_ruby_version = '>= 3.2'

  s.add_dependency 'eac_ruby_utils', '~> 0.131'

  s.add_development_dependency 'eac_ruby_gem_support', '~> 0.13'
end
