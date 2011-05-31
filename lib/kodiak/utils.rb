module Kodiak
	
	def self.log
		file = File.open("#{Kodiak::LOG_FILENAME}", "a+")

   	time = Time.now.strftime("%A, %m/%d/%Y at %I:%M:%3N %p")
		message = "#{Kodiak.user['name']} (#{Kodiak.user['email']}) at #{time} \n\n"
		
		file.write(message)
		file.close
	end
	
end