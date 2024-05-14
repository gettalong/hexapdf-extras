# frozen_string_literal: true

require_relative 'lib/hexapdf/extras/version'

PKG_FILES = Dir.glob([
                       'lib/**/*.rb',
                       'test/**/*.rb',
                       'Rakefile',
                       'LICENSE',
                       'README.rdoc',
                     ])

Gem::Specification.new do |s|
  s.name = 'hexapdf-extras'
  s.version = HexaPDF::Extras::VERSION
  s.summary = 'Additional functionality for HexaPDF'
  s.license = 'MIT'

  s.files = PKG_FILES.to_a

  s.require_path = 'lib'
  s.add_dependency('hexapdf', '~> 0.42')
  s.add_development_dependency('rqrcode_core', '~> 1.2')
  s.add_development_dependency('ruby-zint', '~> 1.3')
  s.required_ruby_version = '>= 2.7'

  s.author = 'Thomas Leitner'
  s.email = 't_leitner@gmx.at'
  s.homepage = 'https://hexapdf-extras.gettalong.org'
end
