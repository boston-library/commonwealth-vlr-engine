# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commonwealth-vlr-engine/version'

Gem::Specification.new do |s|
  s.name          = 'commonwealth-vlr-engine'
  s.version       = CommonwealthVlrEngine::VERSION
  s.authors       = ['Eben English', 'Steven Anderson', 'Ben Barber']
  s.email         = ['eenglish@bpl.org', 'sanderson@bpl.org', 'bbarber@bpl.org']
  s.summary       = %q{Blacklight plugin for virtual local repositories from Digital Commonwealth}
  s.homepage      = ''
  s.license       = 'Apache 2.0'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '~> 2.4'

  s.add_dependency 'rails', '>= 5', '< 6'
  s.add_dependency 'blacklight', '6.19.2'
  s.add_dependency 'blacklight_advanced_search', '6.4.1'
  s.add_dependency 'blacklight-gallery', '0.11.0'
  s.add_dependency 'blacklight-maps', '0.5.1'
  s.add_dependency 'blacklight_range_limit', '~> 6.3.3'
  s.add_dependency 'font-awesome-sass', '4.1.0'
  s.add_dependency 'bpluser', '~> 0.1.19'
  s.add_dependency 'typhoeus', '1.3.1'
  s.add_dependency 'unicode', '~> 0.4.0'
  s.add_dependency 'madison', '~> 0.5.0'
  s.add_dependency 'rsolr', '>= 1.0', '< 3'
  s.add_dependency 'iiif-presentation', '~> 0.2.0'
  s.add_dependency 'zipline', '~> 1.0.2'
  s.add_dependency 'faraday', '0.15.4'

  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'pry-rescue'
  s.add_development_dependency 'pry-stack_explorer'
  s.add_development_dependency 'solr_wrapper', '2.1.0'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'rspec-rails', '3.8'
  s.add_development_dependency 'engine_cart', '~> 2.2'
  s.add_development_dependency 'capybara', '>= 2', '< 4'
end
