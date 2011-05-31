require 'rubygems'
require 'rbconfig'
require 'rake'
require 'echoe'

$: << File.expand_path(File.dirname(__FILE__) + "/lib")
require 'kodiak'

Echoe.new(Kodiak::APP_NAME.downcase, Kodiak::VERSION) do |p|
  p.description    = "The description"
	p.summary 			 = "The summary"
  p.url            = "http://github.com/imulus/kodiak"
  p.author         = "Imulus"
  p.email          = "developer@imulus.com"
  p.ignore_pattern = ["tmp/*", "script/*", "test/*", "assets/*"]
  
  target_os = Config::CONFIG['target_os']

  dependencies = Array.new
  dependencies << "term-ansicolor >=1.0.5"
  dependencies << "directory_watcher >=1.4.0"
  
  if target_os =~ /darwin/i
    dependencies << "rb-appscript >=0.6.1"
  elsif target_os =~ /linux/i
  elsif target_os =~ /mswin|mingw/i
  end
  
  p.development_dependencies = dependencies
	p.runtime_dependencies = dependencies
end