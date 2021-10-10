# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "rb_sdl2"
  spec.version       = "0.1.0"
  spec.author        = "shinokaro"
  spec.email         = "shinokaro@hotmail.co.jp"
  spec.summary       = "Multimedia library with SDL."
  spec.description   = "RbSDL2 treats the functions and pointers provided by SDL as Ruby objects."
  spec.license       = "Zlib"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.add_dependency "ffi", ">= 1.15.0"
  spec.add_dependency "sdl2-bindings", ">= 0.0.7"
end
