# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sharks/version'

Gem::Specification.new do |spec|
  spec.name          = "sharks"
  spec.version       = Sharks::VERSION
  spec.authors       = ["scrub"]
  spec.email         = ["scrub.mx@gmail.com"]

  spec.summary       = %q{Sharks With Lasers Beams Attached To Their Heads.}
  spec.description   = %q{A utility for arming (creating) many bees (Digital Ocean Droplets) to attack (load test) targets (web applications).}
  spec.homepage      = "http://solucionesdigitales.com/sharks."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://solucionesdigitales.com/sharks"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["sharks"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "http"
  spec.add_dependency "net-ssh"
  spec.add_dependency "formatador"
  spec.add_dependency "colorize"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
