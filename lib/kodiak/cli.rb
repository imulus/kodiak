module Kodiak

	def self.push(options)
		ARGV.shift
		
		if ! ARGV[0]
			puts "Push requires an environment parameter"
			puts "Example: 'kodiak push remote'"
			exit
		end

		options[:environment] = ARGV[0]
		config = Kodiak::ConfigReader.new(options)

		if options[:force]
			continue = "yes"
		else
			puts "\nPush these files? ---------"
			puts "[environment = #{options[:environment]}]"
			config.files.each do |file|
				puts "  - #{file[:source]} --> #{file[:destination]}"
			end
			puts "Continue? [yes|no]"
			continue = STDIN.gets.chomp
		end


		if continue =~ /([Yy][Ee][Ss]|[Yy]|1)/
			Kodiak::Transporter.new(config, options)
		else
			puts "Push canceled by user"
			exit
		end
	end	


	def self.watch(options)


		ARGV.shift
		
		if ! ARGV[0]
			puts "Watch requires an environment parameter"
			puts "Example: 'kodiak watch remote'"
			exit
		end

		options[:environment] = ARGV[0]
		config = Kodiak::ConfigReader.new(options)

		if options[:force]
			continue = "yes"
		else
			puts "Start Kodiak watch? [yes|no]"
			continue = STDIN.gets.chomp
		end


		if continue =~ /([Yy][Ee][Ss]|[Yy]|1)/
			Kodiak::Transporter.new(config, options)
			require 'directory_watcher'

			dw = DirectoryWatcher.new '.', :glob => '**/*.txt'
			dw.add_observer do |*args| 
				args.each do |event| 
					puts event.inspect

				end
			end

			dw.interval = 0.5
			dw.stable = 2

			dw.start
			STDIN.gets
			dw.stop			
		end


	end

	
	def self.usage
	  file = File.open("#{Kodiak::CONFIG_PATH}/#{Kodiak::USAGE_FILENAME}", 'r')
		puts file.read
		file.close
	end



end	
