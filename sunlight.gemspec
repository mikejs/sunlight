Gem::Specification.new do |s|
  s.name = "sunlight"
  s.version = "0.2.0"
  s.date = "2009-03-01"
  s.summary = "Library for accessing the Sunlight Labs API."
  s.email = "luigi.montanez@gmail.com"
  s.homepage = "http://github.com/luigi/sunlight"
  s.authors = ["Luigi Montanez"]
  s.files = ['sunlight.gemspec', 'lib/sunlight.rb', 'lib/sunlight/district.rb', 
    'lib/sunlight/legislator.rb', 'README.textile', 'CHANGES.textile']
  s.add_dependency("json", [">= 1.1.3"])
  s.add_dependency("ym4r", [">= 0.6.1"])
  s.has_rdoc = true
end