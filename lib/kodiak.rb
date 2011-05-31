require 'yaml'
require 'kodiak/cli'
require 'kodiak/notification'
require 'kodiak/generator'
require 'kodiak/config_reader'
require 'kodiak/transporter'
require 'kodiak/watcher'

module Kodiak
	APP_NAME 				= "Kodiak"
	VERSION 				= "0.0.1"
	ROOT_PATH 			= Dir.pwd
	CONFIG_PATH 		= File.expand_path(File.dirname(__FILE__) + "/../config")
	CONFIG_FILENAME = "kodiak.yaml"
	CONFIG_ICON 		= "kodiak-icon.png"
	USAGE_FILENAME 	= "kodiak-usage.txt"
end