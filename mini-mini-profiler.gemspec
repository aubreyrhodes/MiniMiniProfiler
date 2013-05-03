Gem::Specification.new do |s|
	s.name = "mini-mini-profiler"
	s.version = "0.1.1"
	s.summary = "Simple Profiler for learning about Rails Development"
	s.authors = ["Aubrey Rhodes"]
	s.description = "Simple Profiler for learning about Rails Development"
	s.email = "aubrey.c.rhodes@gmail.com"
	s.homepage = "https://github.com/aubreyrhodes/MiniMiniProfiler"
	s.files = [
		'mini-mini-profiler.gemspec',
	].concat( Dir.glob('Ruby/lib/**/*').reject {|f| File.directory?(f) || f =~ /~$/ } )
	s.extra_rdoc_files = [
		"Ruby/README.md",
    "Ruby/CHANGELOG"
	]
	s.add_runtime_dependency 'rack', '>= 1.1.3'
  if RUBY_VERSION < "1.9"
    s.add_runtime_dependency 'json', '>= 1.6'
  end

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'activerecord', '~> 3.0'

  s.require_paths = ["Ruby/lib"]
end
