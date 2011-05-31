require 'appscript'
require 'term/ansicolor'
include Term::ANSIColor

module Kodiak
  class Notification

		attr_accessor :growl, :application, :icon, :default_notifications, :notifications, :type, :message

		def initialize(message, type = "message")
      @message = message
      @type = type
			
			console_notify
			
			if Config::CONFIG['target_os'] =~ /darwin/i
				@growl = Appscript.app("GrowlHelperApp");
			
				if @growl.is_running?
					growl_register
					growl_notify
				end
			end
		end


    def console_notify
    	case @type
    	when "success"
        print @message.green
    	when "warning"
        print @message.yellow
      when "failure"
        print @message.red
    	else
        print @message.white
    	end
    end


		# trigger a growl notification
		def growl_notify
			options = { :title => @application,
									:description => @message.gsub(/[\n]+/, ""),
									:application_name => @application,
									:image_from_location => @icon,
									:sticky => false,
									:priority => 0,
									:with_name => notifications.first }
      @growl.notify options			
		end	


		# register Kodiak as an application with Growl
    def growl_register
			@application = Kodiak::APP_NAME
			@icon = "#{Kodiak::CONFIG_PATH}/#{Kodiak::CONFIG_ICON}"
	    @default_notifications = ["Kodiak Success"]
	    @notifications = ["Kodiak Success", "Kodiak Failure"]
      @growl.register(:as_application => @application, :all_notifications => @notifications, :default_notifications => @default_notifications)
    end


	end
end