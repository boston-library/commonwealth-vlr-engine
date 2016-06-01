# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commonwealth-vlr-engine/version'

Gem::Specification.new do |spec|
  spec.name          = 'commonwealth-vlr-engine'
  spec.version       = CommonwealthVlrEngine::VERSION
  spec.authors       = ['Eben English', 'Steven Anderson']
  spec.email         = ['eenglish@bpl.org', 'sanderson@bpl.org']
  spec.summary       = %q{Blacklight plugin for virtual local repositories from Digital Commonwealth}
  spec.homepage      = ''
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '~>4.2.0'
  spec.add_dependency 'blacklight', '6.2.0'
  spec.add_dependency 'blacklight_advanced_search', '6.0.2'
  spec.add_dependency 'blacklight-gallery', '0.5.0'
  spec.add_dependency 'blacklight-maps', '0.4.0'
  spec.add_dependency 'bootstrap-sass', '~> 3.0'
  spec.add_dependency 'font-awesome-sass', '4.1.0'
  spec.add_dependency 'bpluser'
  #, '~> 0.0.7'
  spec.add_dependency 'typhoeus'
  spec.add_dependency 'devise-guests', '0.3.3'
  spec.add_dependency 'omniauth'
  spec.add_dependency 'omniauth-ldap'
  spec.add_dependency 'omniauth-facebook'
  spec.add_dependency 'unicode'
  spec.add_dependency 'omniauth-polaris'
  spec.add_dependency 'madison', '~> 0.5.0'
  spec.add_dependency 'osullivan'


  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec-rails', '~> 3.0'
  spec.add_development_dependency 'jettywrapper'
  spec.add_development_dependency 'engine_cart', '~> 0.4.0'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'poltergeist', '>= 1.5.0'
end
