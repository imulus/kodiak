// require utils

var Map = Map || function(params, element){

	var self = Utils.extend(params, this);

	self.initialize = function(){
		self.build();
		return self;
	};


	self.build = function(){
		var start = {
			zoom : parseInt(self.zoom),
			center : new google.maps.LatLng(self.lat, self.lng),
			mapTypeId : google.maps.MapTypeId[self.type]
		}

    self.canvas = new google.maps.Map(document.getElementById(element), start);
		return self;		
	};

	return self.initialize();
};







