module Kodiak
  class Transporter

		attr_accessor :config, :options, :files, :pushed, :ignored

		def initialize(config, options)
			@config 	= config
			@files 		= @config.files
			@files 		= @config.files
			@options 	= options
		end


		def transport(files = nil)
			@pushed = @ignored = 0
			@files = files || @files
			if @config.ftp?
				ftp
			else
				local
			end
		end


		def local
			puts "\nPushing to [#{@options[:environment]}]"

			@files.each do |file|
				source 			= file[:source]
				destination = file[:destination]

				if @options[:force]
					push source, destination

				elsif File.exists? destination
					source_changed 			= File.ctime(source)
					destination_changed = File.ctime(destination)

					# check if destination is older than source
					if (destination_changed <=> source_changed) == -1
						push source, destination
					else
						ignore source, destination, "Destination file was newer than source. Use --force to force overwrite."
					end

				else
					push source, destination
				end
			end

			if ! @options[:quiet]
		  	Kodiak::Notification.new "\nPushed #{@pushed} files, Ignored #{@ignored} files\n\n", "success"
			end
		end


		def ftp
			require 'net/ftp'
			credentials = @config.ftp

			puts "Connecting to #{credentials['server']}..."

		  Net::FTP.open credentials['server'] do |ftp|
		    ftp.login credentials['username'], credentials['password']
		    ftp.chdir credentials['path']

				@files.each do |file|
					source 			= file[:source]
					destination = file[:destination]

					if not File.directory? source
						folders = destination.split("/")
						filename = folders.pop

						folders.each do |folder|
							if not ftp.nlst.index(folder)
								puts "- /#{folder} not found. Creating."
								ftp.mkdir folder
							end
							puts "- opening directory /#{folder}"
							ftp.chdir folder
						end

						puts "+ pushing #{filename}"
						if File.directory? filename
							ftp.mkdir filename
						else
							ftp.put source, filename
						end
						folders.length.times { ftp.chdir("..") }
					end
				end
		  end
		end


		def push(source, destination)
			FileUtils.cp_r source, destination, :remove_destination => true
			Kodiak.log
			
			if @options[:verbose] 
		  	Kodiak::Notification.new "Pushed #{source} --> #{destination}\n"
			else
				puts " - Pushed #{source} --> #{destination}\n"
			end
			
			@pushed += 1
		end

		def ignore(source, destination, reason)
			Kodiak.log
			if @options[:verbose] 
	  		Kodiak::Notification.new "Ignored #{source}\n     - #{reason}\n"
			else
	  		puts "Ignored #{source}\n     - #{reason}\n"	
			end
			
			@ignored += 1
		end

  end
end