require 'rake/clean'
require 'rake/testtask'
require 'rubygems/package_task'

Rake::TestTask.new do |t|
  t.libs << 'test' << '../hexapdf/lib'
  t.test_files = FileList['test/**/*.rb']
  t.verbose = false
  t.warning = true
end

CLOBBER << 'webgen-out'
CLOBBER << 'webgen-tmp'
CLOBBER << 'coverage'

task default: 'test'

spec = eval(File.read('hexapdf-extras.gemspec'), binding, 'hexapdf-extras.gemspec')
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Upload the release to Rubygems"
task publish_files: [:package] do
  sh "gem push pkg/hexapdf-extras-#{HexaPDF::Extras::VERSION}.gem"
  puts 'done'
end

task :test_all do
  versions = `rbenv versions --bare | grep -i 3.`.split("\n")
  versions.each do |version|
    sh "eval \"$(rbenv init -)\"; rbenv shell #{version} && ruby -v && rake test"
  end
  puts "Looks okay? (enter to continue, Ctrl-c to abort)"
  $stdin.gets
end

desc "Release HexaPDF Extras version #{HexaPDF::Extras::VERSION}"
task release: [:clobber, :test_all, :package, :publish_files]

