# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "saruman/version"

Gem::Specification.new do |s|
  s.name        = "saruman"
  s.version     = Saruman::VERSION
  s.authors     = ["Jason Ayre"]
  s.email       = ["jasonayre@gmail.com"]
  s.homepage    = "https://github.com/jasonayre/saruman.git"
  s.summary     = %q{Magento Extension command line generator}
  s.description = %q{Lets you create magento extensions, add models, etc}

  s.rubyforge_project = "saruman"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  
  s.add_dependency "activesupport", "~> 3.0.0"
  s.add_dependency "thor"
  s.add_dependency "highline"
  s.add_dependency "nokogiri"
  s.add_dependency "roxml"  
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "aruba"
  
end
