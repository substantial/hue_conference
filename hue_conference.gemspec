# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hue_conference/version'

Gem::Specification.new do |gem|
  gem.name          = "hue_conference"
  gem.version       = HueConference::VERSION
  gem.authors       = ["Shawn Dempsey", "Shaun Dern"]
  gem.email         = ["sndempsey@gmail.com", "smdern@gmail.com"]
  gem.description   = %q{Use Google Calendar events to affect Philips Hue Wifi Lightbulbs}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/substantial/hue_conference"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "ruhue", "~> 0.1.0"
  gem.add_dependency "google-api-client", "~> 0.6.3"
  gem.add_development_dependency 'rspec'
end
