# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll/action-network/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-action-network"
  spec.version       = Jekyll::ActionNetwork::VERSION
  spec.authors       = ["Joe Irving"]
  spec.email         = ["joe@tippingpointuk.org"]

  spec.summary       = "Generate Jekyll collection(s) from Action Network"
  spec.description   = ""
  spec.homepage      = "https://github.com/joe-irving/jekyll-action-network/"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #  `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files = Dir["lib/**/*.rb", "lib/**/*.yaml", "lib/**/*.yml"]
  # end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5"

  spec.add_runtime_dependency "action_network_rest", "~> 0.10.0"
  spec.add_runtime_dependency "dotenv", "~> 2.8", ">= 2.8.0"
  spec.add_runtime_dependency "jekyll", "~> 4.2", ">= 4.2.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.11.0"
  spec.add_development_dependency "rubocop", "~> 1.36.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end
