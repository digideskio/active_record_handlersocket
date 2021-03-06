# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_record_handlersocket/version"

Gem::Specification.new do |s|
  s.name        = "active_record_handlersocket"
  s.version     = ActiveRecordHandlersocket::VERSION
  s.authors     = ["Takayuki Sugita"]
  s.email       = ["sugilog@gmail.com"]
  s.homepage    = "https://github.com/sugilog/active_record_handlersocket"
  s.summary     = %q{HandlerSocket for ActiveRecord}
  s.description = %q{Easy-to-use handlersocket from existing ActiveRecord Models}

  s.files         = `git ls-files`.split("\n").select{|f| f !~ /^examples\// }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "handlersocket", "~> 0.0.2"

  case
  when RUBY_VERSION < "1.9.0"
    s.add_runtime_dependency "activerecord", "~> 2.3.12"

    s.add_development_dependency 'rake',             "~> 0.9.2.2"
    s.add_development_dependency "mysql2",           "0.2.18"
    s.add_development_dependency "rspec",            "~> 2.11.0"
    s.add_development_dependency "factory_girl",     "2.3.2"
    s.add_development_dependency "database_cleaner", "0.9.1"
  when RUBY_VERSION < "2.0.0"
    s.add_runtime_dependency "activerecord", "~> 3.2.18"

    s.add_development_dependency "rake"
    s.add_development_dependency "mysql2"
    s.add_development_dependency "rspec"
    s.add_development_dependency "rspec-its"
    s.add_development_dependency "factory_girl"
    s.add_development_dependency "database_cleaner"
  else
    s.add_runtime_dependency "activerecord"

    s.add_development_dependency "rake"
    s.add_development_dependency "mysql2"
    s.add_development_dependency "rspec"
    s.add_development_dependency "rspec-its"
    s.add_development_dependency "factory_girl"
    s.add_development_dependency "database_cleaner"
  end
end
