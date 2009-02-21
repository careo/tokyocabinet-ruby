Gem::Specification.new do |s|
  s.name = %q{tokyocabinet}
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mikio Hirabayashi"]
  s.date = %q{2009-02-15}
  s.description = %q{}
  s.email = %q{mikio@users.sourceforge.net}
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = []
  s.files = %w{
    ext/MANIFEST
    ext/extconf.rb
    ext/tokyocabinet.c
    ext/tokyocabinet-doc.rb
    ext/tchtest.rb
    ext/tcbtest.rb
    ext/tcftest.rb
    ext/tcttest.rb
    ext/test.rb
    ext/example/tchdbex.rb
    ext/example/tcbdbex.rb
    ext/example/tcfdbex.rb
    ext/example/tctdbex.rb
    ext/COPYING
  }
  s.has_rdoc = false
  s.homepage = %q{}
  s.rdoc_options = []
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{=}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

