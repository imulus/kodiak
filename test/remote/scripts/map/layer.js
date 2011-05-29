// require utils

var Layer = function(params){
	
	var self = Utils.extend(params, this);

	self.initialize = function(){
		self.hidden = false;
		return self;
	};

	self.show = function(){
		return self;
	};	

	self.hide = function(){
		return self;
	};
	
	return self.initialize();
};