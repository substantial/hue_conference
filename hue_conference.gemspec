# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hue_conference/version'

Gem::Specification.new do |spec|
  spec.name          = "hue_conference"
  spec.version       = HueConference::VERSION
  spec.authors       = ["Shawn Dempsey", "Shaun Dern"]
  spec.email         = ["sndempsey@gmail.com", "smdern@gmail.com"]
  spec.description   = %q{Use Google Calendar events to affect Philips Hue Wifi Lightbulbs}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/substantial/hue_conference"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency "ruhue", "~> 0.1.0"
  spec.add_dependency "google-api-middle_man", "~> 0.2.1"
  spec.add_dependency "color", "~> 1.4.2"

  spec.add_development_dependency 'rspec'
end

