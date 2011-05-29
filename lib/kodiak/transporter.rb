module Kodiak
  class Transporter

		attr_accessor :config, :options, :files

		def initialize(config, options)
			@config = config
			@files = @config.files
			@options = options
			transport
		end
		

		def transport
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