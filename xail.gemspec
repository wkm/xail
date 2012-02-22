# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "xail/version"

Gem::Specification.new do |s|
  s.name        = "xail"
  s.version     = Xail::VERSION
  s.authors     = ["Wiktor Macura"]
  s.email       = ["wiktor@tumblr.com"]
  s.homepage    = ""
  s.summary     = %q{tail for winners}
  s.description = %q{TODO write this}

  s.rubyforge_project = "xail"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "trollop"
  s.add_runtime_dependency "term-ansicolor"
end
