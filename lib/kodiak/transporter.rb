module Kodiak
  class Transporter

		attr_accessor :config, :options, :files

		def initialize(config, options)
			@config = config
			@files = @config.files
			@options = options

			if @config.ftp?
				transport_ftp
			else
				transport_local
			end
		end


		def transport_local
			puts "Pushing to [#{@options[:environment]}]"

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
						ignore source, destination
					end

				else
					push source, destination
				end
			end
		end


		def transport_ftp
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
			puts "  - Pushed #{source} --> #{destination}"
		end

		def ignore(source, destination)
			puts "  - Ignored #{source}"
			puts "      Destination file was older than source"
		end

  end
end