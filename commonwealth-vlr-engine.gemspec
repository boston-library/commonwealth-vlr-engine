# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commonwealth-vlr-engine/version'

Gem::Specification.new do |s|
  s.name          = 'commonwealth-vlr-engine'
  s.version       = CommonwealthVlrEngine::VERSION
  s.authors       = ['Eben English', 'Steven Anderson', 'Ben Barber']
  s.email         = ['eenglish@bpl.org', 'sanderson@bpl.org', 'bbarber@bpl.org']
  s.summary       = 'Blacklight plugin for virtual local repositories from Digital Commonwealth'
  s.homepage      = 'https://github.com/boston-library/commonwealth-vlr-engine'
  s.license       = 'Apache 2.0'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.0.6', '< 3.1'

  s.add_dependency 'blacklight', '~> 7.19.0'
  s.add_dependency 'blacklight_advanced_search', '~> 7.0.0'
  s.add_dependency 'blacklight-gallery', '~> 2.1.0'
  s.add_dependency 'blacklight_iiif_search', '~> 2.0'
  s.add_dependency 'blacklight-maps', '~> 1.1.0'
  s.add_dependency 'blacklight_range_limit', '>= 7.8.2', '< 8.0'
  s.add_dependency 'font-awesome-sass', '~> 5.0'
  s.add_dependency 'iiif-presentation', '~> 1.1'
  s.add_dependency 'madison', '~> 0.5.0'
  s.add_dependency 'rails', '~> 6.1.7.4'
  s.add_dependency 'recaptcha', '~> 5.12'
  s.add_dependency 'rsolr', '>= 1.0', '< 3'
  s.add_dependency 'rss', '~> 0.2.9'
  s.add_dependency 'typhoeus', '~> 1.3'
  s.add_dependency 'unicode', '~> 0.4.4'
  s.add_dependency 'view_component', '>= 2.82.0', '< 3.0'
  s.add_dependency 'zipline', '~> 1.3.1'

  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'capybara', '~> 3.0', '< 4'
  s.add_development_dependency 'engine_cart', '~> 2.2'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'pry-rescue'
  s.add_development_dependency 'pry-stack_explorer'
  s.add_development_dependency 'rspec-rails', '~> 6.0.3'
  s.add_development_dependency 'solr_wrapper', '~> 3.1'
end
