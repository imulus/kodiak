require 'fileutils'

module Kodiak
  class ConfigReader

		attr_accessor :options, :input, :files, :environment, :user

		def initialize(options)
			@options = options
			@environment = @options[:environment]			
			@input = get_config
			@files = []
			check_and_set_globals
			find_and_add_files
		end
		
		
		def find_and_add_files
			if @input[@environment]
				@input[@environment]['files'].each do |source, destination|
					Dir.glob(source).each do |file|
						input = { :source => file, :destination => destination }				
						@files.push input
					end
				end
			else
				puts "Environment '#{environment}' is not defined in kodiak.yaml"
				puts "Environments defined:"
				@input.each do |name, environment|
					puts "- #{name}"
				end
				exit
			end
		end


		def ftp?
			@input[@environment]['ftp'] || false			
		end
		

		def ftp
			environment = @input[@environment]
			
			# supply a default path of root
			if ! environment['path']
				environment['path'] = ""
			end

			credentials = {}
			items = ['server','username','password','path']
			
			#check that they provided all the creds we need
			items.each do |item|
				if ! environment[item]
					puts "Missing FTP credential: #{item}"
					exit
				else
					credentials[item] = environment[item]
				end
			end
			return credentials
		end
		
		def get_config
			if File.exists?(Kodiak::CONFIG_FILENAME)
				begin
					config = YAML.load(File.open(Kodiak::CONFIG_FILENAME))
					if config.class == Hash && ! config.empty?
				  	return config
					else					  
            Kodiak::Notification.new "Kodiak configuration exists but has not been defined yet. Configure it in #{Kodiak::CONFIG_FILENAME}\n", "failure"
						system("open #{Kodiak::CONFIG_FILENAME}")
						exit(0)
					end
				rescue ArgumentError => e
          Kodiak::Notification.new "Could not parse YAML: #{e.message}\n", "failure"
				  exit
				end
			else
        Kodiak::Notification.new "Could not find a Kodiak configuration file in this directory. Use 'kodiak generate' to create one.\n", "failure"
				exit
			end
		end
		
		def check_and_set_globals
			if File.exists? "#{ENV['HOME']}/#{Kodiak::GLOBAL_CONFIG}"
				begin
					user = YAML.load(File.open("#{ENV['HOME']}/#{Kodiak::GLOBAL_CONFIG}"))
					if user.class == Hash && ! user.empty?
						Kodiak.user = user
						@user = user						
					else					  
            Kodiak::Notification.new "Kodiak has not been globally configured or the configuration is broken\n", "failure"
						puts "To configure, use:"
						puts 'kodiak configure --user.name "Firstname Lastname" --user.email "your_email@youremail.com"'
						exit
					end
				rescue ArgumentError => e
         puts "Could not parse YAML: #{e.message}\n"
				  exit
				end
			else
        Kodiak::Notification.new "Kodiak has not been globally configured or the configuration is broken\n", "failure"
				puts "To configure, use:"
				puts 'kodiak configure --user.name "Firstname Lastname" --user.email "your_email@youremail.com"'
				exit
			end
		end
		

  end
end