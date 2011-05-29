// require utils

var Polygon = function(params){
	
	var self = Utils.extend(params, this);
	self.paths = {};
	
	self.initialize = function(){
		self.hidden = false;
		self.build();
		return self;		
	};
	
	
	self.build = function(){
		
		var points = self.points;
		self.points = {};
		
		for ( var index in points ) {
			self.addPoint(points[index]);
		}
		
		console.log(self.points);
		

		return self;
	};
	
	
	self.addPoint = function(point){
		var point = new Point( point );
		self.points[point.id] = point;
		self.paths[point.id]  = point.path();
		return point;		
	};


	self.show = function(){
		return self;		
	};
	
	
	self.hide = function(){
		return self;
	};	
	
	return self.initialize();
};