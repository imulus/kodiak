module Kodiak
	
	def self.log(params={})
		pushed = params[:pushed]
		ignored = params[:ignored]

		file = File.open("#{Kodiak::LOG_FILENAME}", "a+")

   	time = Time.now.strftime("%A, %m/%d/%Y at %I:%M:%3N %p")
		message = "#{time} | #{Kodiak.user['name']} (#{Kodiak.user['email']})\n"
		message += "---------------------------------------------------------------------------------\n"
		message += "Pushed #{pushed.length} files and ignored #{ignored.length} files\n"
		message += "---------------------------------------------------------------------------------\n"
		
		pushed.each do |file|
			message += "Pushed [#{file[:source]}] --> [#{file[:destination]}]\n"			
		end
		
		ignored.each do |file|
			message += "Ignored #{file[:source]} because #{file[:reason].downcase}\n"			
		end		

		message += "\n\n\n"
		
		file.write(message)
		file.close
	end
	
end