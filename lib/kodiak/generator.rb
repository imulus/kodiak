module Kodiak
  class Generator

		attr_accessor :options

		def initialize(options)
			@options = options
		end

		def generate
			if config_exists? && ! options[:force]
        puts "Kodiak config already exists in this directory. Use --force to overwrite.\n"
			elsif (!config_exists?) || (config_exists? && options[:force])
				copy_config
			end
		end

		# check to see if Kodiak.yaml already exists in directory
		def config_exists?
			File.exists?(Kodiak::CONFIG_FILENAME)
		end

		# copy sample Kodiak.yaml to directory
		def copy_config
			FileUtils.cp_r "#{Kodiak::CONFIG_PATH}/#{Kodiak::CONFIG_FILENAME}", "#{Kodiak::CONFIG_FILENAME}", :remove_destination => true
			puts "Kodiak configuration created at #{Kodiak::CONFIG_FILENAME}\n\n"
		end

  end
end