var Overlay = function(layer, data){

	var self = this;

	self.initialize = function(){
		self.data = data;
		self.data.paths = [];
		self.hidden = false;
		self.layer = layer;
		self.map = map = self.layer.map;
		self.build();
		return self;
	};


	self.build = function(){
	  self.polygon = new google.maps.Polygon(this.data);

		for ( var index in self.data.points ) {
			self.addPoint({lat : self.data.points[index].lat, lng: self.data.points[index].lng});
		}

	  self.polygon.setMap(self.map.canvas);
	};


	self.addPoint = function(points){
		self.data.paths.push( new google.maps.LatLng(points.lat, points.lng) );
		self.data.points.push(points);
		self.polygon.setPaths(self.data.paths);
	};


	self.show = function(){
	  self.polygon.setMap(self.map.canvas);
		self.hidden = false;
		return self;
	};



	self.hide = function(){
		self.polygon.setMap(null);
		self.hidden = true;
		return self;
	};


	self.remove = function(){
		self.hide();
		return self;
	};
	
	
	self.draw = function(){
		self.map.canvas.setOptions({ draggableCursor: 'crosshair' });

		self.data.paths = [];
		self.data.points = [];

	  google.maps.event.addListener(self.map.canvas, 'click', function(mdEvent) {

			google.maps.event.addListener(self.map.canvas, 'mousemove', function(event) {
				self.addPoint({ lat: event.latLng.lat(), lng: event.latLng.lng() });
		  });

			google.maps.event.addListener(self.map.canvas, 'click', function(event) {
				google.maps.event.clearListeners(self.map.canvas);
				google.maps.event.clearListeners(self.polygon);
		  });

			google.maps.event.addListener(self.polygon, 'mousemove', function(event) {
				self.addPoint({ lat: event.latLng.lat(), lng: event.latLng.lng() });
		  });

			google.maps.event.addListener(self.polygon, 'click', function(event) {
				google.maps.event.clearListeners(map.canvas);
				google.maps.event.clearListeners(self.polygon);
		  });

		});

	};	


	return self.initialize();
};