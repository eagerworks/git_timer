# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "git_timer/version"

Gem::Specification.new do |spec|
  spec.name          = "git_timer"
  spec.version       = GitTimer::VERSION
  spec.authors       = ["Mauro Mottini", "Guillermo Aguirre"]
  spec.email         = ["hello@eagerworks.com"]

  spec.summary       = %q{Simple time and activity tracker for git}
  spec.description   = %q{Simple time and activity tracker for git}
  spec.homepage      = "https://github.com/eagerworks/git_timer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
end
