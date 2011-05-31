require 'directory_watcher'

module Kodiak
  class Watcher

		attr_accessor :config, :options, :files
		
		def initialize(config, options)
			@config = config
			@files = config.files
			@options = options
			watch
		end

		def watch
			transporter = Kodiak::Transporter.new(config, options)

			dw = []
			@files.each do |file|
				dw = DirectoryWatcher.new '.', :glob => file[:source], :pre_load => true
				dw.add_observer do |*args| 
					args.each do |event| 
						if event.type == :stable then transporter.transport [file] end
					end
				end
				dw.interval = 0.25 	# polling interval
				dw.stable = 2 			# mutiple of interval for 'stable' events
				dw.start
			end		
			puts "Kodiak server started"
			STDIN.gets
			dw.stop			
		end
		
	end
end
