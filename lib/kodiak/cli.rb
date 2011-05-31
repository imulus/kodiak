module Kodiak

	def self.push(options)
		ARGV.shift

		if ! ARGV[0]
      Kodiak::Notification.new "Push requires an environment parameter\n", "failure"			
			puts "Example: 'kodiak push remote'"
			exit
		end

		options[:environment] = ARGV[0]
		config = Kodiak::ConfigReader.new(options)

		if options[:safe]
			continue = "yes"
		else
			puts "[environment = #{options[:environment]}]\n"
			puts "\nPush these files?"
			config.files.each do |file|
				puts "  - #{file[:source]} --> #{file[:destination]}"
			end
			puts "\nContinue? [yes|no]"
			continue = STDIN.gets.chomp
		end


		if continue =~ /([Yy][Ee][Ss]|[Yy]|1)/
			Kodiak::Transporter.new(config, options).transport
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

		if options[:safe]
			continue = "yes"
		else
			puts "Start Kodiak server? [yes|no]"
			continue = STDIN.gets.chomp
		end

		if continue =~ /([Yy][Ee][Ss]|[Yy]|1)/
			Kodiak::Watcher.new(config, options)
		end
	end


	def self.configure(options)
		if not File.exists? "#{ENV['HOME']}/#{Kodiak::GLOBAL_CONFIG}"
			FileUtils.cp_r "#{Kodiak::CONFIG_PATH}/#{Kodiak::GLOBAL_CONFIG}", "#{ENV['HOME']}/#{Kodiak::GLOBAL_CONFIG}", :remove_destination => true
		end

		user = ""
		options.each do |key, value|
		  user += "#{key} : #{value}\n"
		end

		file = File.open("#{ENV['HOME']}/#{Kodiak::GLOBAL_CONFIG}", "w+")
		file.write(user)
		file.close

		Kodiak::Notification.new "Global configuration complete\n", "success"
		Kodiak::Notification.new "#{user}"
	end


	def self.view_log
		if not File.exists? Kodiak::LOG_FILENAME
			puts "Log file does not exist. Sorry."
			exit
		end
		
		file = File.open("#{Kodiak::LOG_FILENAME}", "r")
		puts file.read
		file.close
	end

	def self.usage
	  file = File.open("#{Kodiak::CONFIG_PATH}/#{Kodiak::USAGE_FILENAME}", 'r')
		puts file.read
		file.close
	end



end
