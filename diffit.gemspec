$:.push File.expand_path("../lib", __FILE__)

require 'diffit/version'

Gem::Specification.new do |s|
  s.name        = 'diffit'
  s.version     = Diffit::VERSION
  s.authors     = ['Denis Lifanov']
  s.email       = ['inadsence@gmail.com']
  s.homepage    = 'https://github.com/gazay/diffit'
  s.summary     = 'A simple solution to track changes in your tables.'
  s.description = 'Track changes in your tables using PostgreSQL triggers..'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'pg', '~> 0.18'

  s.add_development_dependency 'rspec-rails',      '~> 3.2'
  s.add_development_dependency 'ammeter',          '~> 1.1'
  s.add_development_dependency 'simplecov',        '~> 0.10'
  s.add_development_dependency 'database_cleaner', '~> 1.4'
  s.add_development_dependency 'yard',             '~> 0.8.7'
  s.add_development_dependency 'redcarpet',        '~> 3.2'
  s.add_development_dependency 'github-markup',    '~> 1.3'

end
