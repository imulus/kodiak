var Utils = Utils || {
	
	extend : function(params, defaults) {
		if( typeof params !== "undefined" && typeof params === "object") {
			for(var index in defaults) {
				if(typeof params[index] === "undefined") { 
					params[index] = defaults[index]; 
				}
			}
			return params;
		}
		else {
			return defaults;
		}
	}
	

	
};
