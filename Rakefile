desc "Run those specs"
task :spec do
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new do |t|
    t.pattern = 'spec/*_spec.rb'
  end
end

task :default => :spec