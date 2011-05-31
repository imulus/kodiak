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
			@pushed = []
			@ignored = []
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

				if @options[:force]
					push file

				elsif File.exists? file[:destination]
					source_changed 			= File.ctime(file[:source])
					destination_changed = File.ctime(file[:destination])

					# check if destination is older than source
					if (destination_changed <=> source_changed) == -1
						push file
					else
						ignore file, "Destination file was newer than source."
					end

				else
					push file
				end
			end

			if ! @options[:quiet]
		  	Kodiak::Notification.new "\nPushed #{@pushed.length} files, Ignored #{@ignored.length} files\n\n", "success"
			else
				puts "\nPushed #{@pushed.length} files, Ignored #{@ignored.length} files\n\n"
			end

			if @options[:verbose] && @ignored.length > 0
				puts "Some files were ignored. Use --force to force overwrite.\n\n"
			end
			
			Kodiak.log :pushed => @pushed, :ignored => @ignored
			
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


		def push(file)
			FileUtils.cp_r file[:source], file[:destination], :remove_destination => true
			
			if @options[:verbose] 
		  	Kodiak::Notification.new "Pushed #{file[:source]} --> #{file[:destination]}\n"
			else
				puts " - Pushed #{file[:source]} --> #{file[:destination]}\n"
			end

			@pushed.push file
		end

		def ignore(file, reason)
			file[:reason] = reason
			if @options[:verbose] 
	  		Kodiak::Notification.new "Ignored #{file[:source]}\n     - #{file[:reason]}\n"
			else
	  		puts "Ignored #{file[:source]}\n     - #{file[:reason]}\n"	
			end
			
			@ignored.push file
		end

  end
end