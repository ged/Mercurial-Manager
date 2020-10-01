# -*- encoding: utf-8 -*-
# stub: mercurial-manager 0.1.0.pre.20201001005737 ruby lib

Gem::Specification.new do |s|
  s.name = "mercurial-manager".freeze
  s.version = "0.1.0.pre.20201001005737"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://todo.sr.ht/~ged/Mercurial-Manager", "changelog_uri" => "https://deveiate.org/code/mercurial-manager/History_md.html", "documentation_uri" => "https://deveiate.org/code/mercurial-manager", "homepage_uri" => "https://hg.sr.ht/~ged/Mercurial-Manager", "source_uri" => "https://hg.sr.ht/~ged/Mercurial-Manager" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2020-10-01"
  s.description = "You can check out the current development source with Mercurial via its project page. Or if you prefer Git, via its Github mirror.".freeze
  s.email = ["ged@faeriemud.org".freeze]
  s.executables = ["hg-ssh".freeze, "refresh-auth".freeze]
  s.files = ["History.md".freeze, "LICENSE.txt".freeze, "README.md".freeze, "bin/hg-ssh".freeze, "bin/refresh-auth".freeze, "lib/mercurial_manager.rb".freeze, "lib/mercurial_manager/ruleset.rb".freeze, "spec/mercurial_manager/ruleset_spec.rb".freeze, "spec/mercurial_manager_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://hg.sr.ht/~ged/Mercurial-Manager".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "You can check out the current development source with Mercurial via its project page.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.17"])
    s.add_runtime_dependency(%q<inifile>.freeze, ["~> 3.0"])
    s.add_runtime_dependency(%q<hglib>.freeze, ["~> 0.10"])
    s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.10"])
  else
    s.add_dependency(%q<loggability>.freeze, ["~> 0.17"])
    s.add_dependency(%q<inifile>.freeze, ["~> 3.0"])
    s.add_dependency(%q<hglib>.freeze, ["~> 0.10"])
    s.add_dependency(%q<rake-deveiate>.freeze, ["~> 0.10"])
  end
end
