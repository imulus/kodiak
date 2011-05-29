// require utils

var Point = function(params){
	
	var self = Utils.extend(params, this);
	var path = null;
	
	self.initialize = function(){
		self.hidden = false;
		return self;		
	};


	self.path = function(){
		if ( ! path ) { path = new google.maps.LatLng(self.lat, self.lng); }
		return path;
	};	
	
	
	return self.initialize();
};