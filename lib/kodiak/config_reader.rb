require 'fileutils'

module Kodiak
  class ConfigReader

		attr_accessor :options, :config, :files

		def initialize(options)
			@options = options
			@config = get_config
			@files = []
			find_and_add_files
		end
		
		
		def find_and_add_files
			environment = @options[:environment]
			if @config[environment]
				@config[environment]['files'].each do |source, destination|
					Dir.glob(source).each do |file|
						input = { :source => file, :destination => destination }				
						@files.push input
					end
				end
			else
				puts "Environment '#{environment}' is not defined in kodiak.yaml"
				puts "Environments defined:"
				@config.each do |name, environment|
					puts "- #{name}"
				end
				exit
			end
		end

		
		def get_config
			if File.exists?(Kodiak::CONFIG_FILENAME)
				begin
					config = YAML.load(File.open(Kodiak::CONFIG_FILENAME))
					if config.class == Hash && ! config.empty?
				  	return config
					else					  
            puts "Kodiak configuration exists but has not been defined yet. Configure it in #{Kodiak::CONFIG_FILENAME}\n"
						exit(0)
					end
				rescue ArgumentError => e
         puts "Could not parse YAML: #{e.message}\n"
				  exit
				end
			else
        puts "Could not find a Kodiak configuration file in this directory. Use 'kodiak generate' to create one.\n"
				exit
			end
		end

  end
end