# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-lwrf-jm"
  s.version     = "0.0.1" 
  s.authors     = ["julianmclean"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{SiriProxy Plugin to control LightwaveRF kit via Pauly's ruby gem}
  s.description = %q{This is a plugin that allows you to control lightwaveRF using Siri}

  s.rubyforge_project = "siriproxy-lwrf-jm"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_runtime_dependency "lightwaverf", "~> 0.3.2"

end
