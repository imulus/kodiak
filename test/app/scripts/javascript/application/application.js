// require utils.hash
// require jquery

var Application = Application || function(data){

	var self = this;
	var fxspeed = 200;
	var hash = new Utils.Hash();
	var $loading = $("#loading");

//

	self.initialize = function(){
		self.map = new Map(data.map, "map");		
		self.panels.init();
		self.layers.init();
		self.overlays.init();
		self.observe();
		return self;
	}

//

	self.observe = function(){

		$("a.flyout-trigger").live('click',function(e){
			e.preventDefault();
			var href = $(this).attr("href");
			var $remote = $(href);




			if( $remote.is(':hidden') ){
				$remote.siblings('.flyout').slideUp(fxspeed);
				$remote.slideDown(fxspeed);				
			}
			else {
				$remote.slideUp(fxspeed);
			}
		});
		return self;
	}






//

	self.panels = {

		init : function(){
			this.build();
			this.observe();
		},

		build : function(){

			if( hash.element() ) {
				var $panel = $(hash.element());
				self.panels.show($panel);
			} else {
				$panel = $('#panel .panel').eq(0);
				self.panels.show($panel);
			}

		},

		observe : function(){

			hash.onChange( function(){
				var $panel = $(hash.element());
				self.panels.show($panel);
			});

			$('.hash-trigger').live('click', function(e){
				e.preventDefault();
				e.stopPropagation();
				var href = $(this).attr("href");
				hash.set(href);
			});

			$('.panel').live('click',function(e){
				if ( $(this).hasClass("active") ) {
					e.stopPropagation();

					var id = $(this).attr("id");

					if ( id ) {
						hash.set(id);
					}

				} else {
					return false;
				}
			});
		},

		show : function($panel){
			var fxs = 200;
			var animation = {};
			var css = {};

			if ( $panel.parents('.panel').length ) {
				animation.opacity = 1;

				if ( $panel.parents('.panel').length == 1 ){
					animation.left = "80px";
				}
				else {
					animation.left = "20px";
				}

				if( $panel.is(':hidden') ){
					css.display = "block";
					css.opacity = 0;
				}
			}

			$panel.parents('.panel').each(function(){
				var css = {
					display : 'block',
					opacity : 1
				};
				if ( $(this).parents('.panel').length == 1 ){
					css.left = "80px";
				}
				else {
					css.left = "0px";
				}
				$(this).css(css).addClass("inactive");
			});

			$panel.css(css).animate(animation, fxs, function(){
				$panel.removeClass("inactive").addClass("active");
			});

			$panel.siblings('.panel').each(function(){
				$(this).removeClass("active").addClass("inactive").fadeOut(fxs, function(){
					$(this).css("left","-100%");
				});
			});

			$panel.children('.panel').each(function(){
				$(this).removeClass("active").addClass("inactive").fadeOut(fxs, function(){
					$(this).css("left","-100%");
				});
			});
		}

	};

//

	self.layers = {

		init : function(){
			this.build();
			this.observe();
		},
		
		build : function(){
			
			self.loader.start();
			
			var layers = self.map.layers;
			self.map.layers = {};

			for ( var index in layers ) {
				var layer = layers[index];
				self.map.layers[layer.id] = new Layer(layer);
			}

			self.layers.refresh();
		},


		observe : function(){

			$(".layer-toggle").live('click', function(e){
				e.preventDefault();
				var id = $(this).attr("rel");
				var layer = self.map.layers[id];
				self.layers.toggle(layer, $(this));
			});

			$('.delete-layer').live('click', function(e){
				e.preventDefault();
				e.stopPropagation();
				var href 	= $(this).attr("href");
				var id 		= $(this).attr("data-layer-id");
				var layer = self.map.layers[id];
				if (confirm("Are you sure?")) {
					self.layers.remove(layer, href);
				}
			});

			$('#new-layer form').submit(function(e){
				e.preventDefault();
				self.loader.start();
				var $map_id = $(this).children("input[name='map_id']");
				var $name = $(this).children("input[name='name']");

				var data = {
					map_id : $map_id.val(),
					name	 : $name.val()
				} 

				$.post("/api/layers/create", data,
					function(layer) {
						self.map.layers[layer.id] = new Layer(layer);						
						$('#new-layer').slideUp(fxspeed);
						$name.val('');
						self.layers.refresh();
					}, 'json'
				);

			});

		},

		
		refresh : function(){
			self.loader.start();
			
			$("#layers > ul.nav").fadeOut(fxspeed, function(){
				$(this).remove();
			});
			
			$("#layers > .panel").fadeOut(fxspeed, function(){
				$(this).remove();
			});			
			
			$.post("/api/layers/index", {},
				function(response) {
					$("#layers").append(response);
					self.panels.build();
					self.loader.stop();
				}
			);			
		},


		toggle : function(layer, $element){

			if ( layer.hidden ) {
				layer.show();
				$element.addClass('active');
			}
			else {
				layer.hide();
				$element.removeClass('active');
			}

		},

		remove : function(layer, href){
			self.loader.start();
			layer.hide();
			var url = "/api/layers/delete/" + layer.id;
			$.post(url, {}, function(response){
				self.loader.stop();
				hash.set(href);
				var $anchor = $("#layers > ul.nav > li > a[rel='" + layer.id + "']");
				var $li = $anchor.parent('li');
				$li.delay(fxspeed).fadeOut(fxspeed);
			});
		}

	};

//

	self.overlays = {

		init : function(){
			this.build();
			this.observe();
		},
		
		build : function(){
			for ( var index in self.map.layers ) {
				var layer = self.map.layers[index];
				
				console.log(layer);
				

				var overlays = layer.overlays;

				layer.overlays = {};
				
				for ( var index in overlays ) {
					var overlay = overlays[index];
					switch ( overlay.type ) {
						case 'polygon' :
							layer.overlays[overlay.id] = new Polygon(overlay);						
							break;							
						case 'marker' : 
							layer.overlays[overlay.id] = new Marker(overlay);						
							break;							
						case 'line' : 
							layer.overlays[overlay.id] = new Line(overlay);						
							break;						
					}
				}
			}

					
		},

		observe : function(){

			$(".draw-overlay").click(function(e){
				e.preventDefault();

				var layer_id = $(this).siblings("input[name='layer_id']").val();

				overlay = map.layers[layer_id].addOverlay({
					layer_id : layer_id,
					points: [{ lat: 0, lng: 0 },{ lat: 0, lng: 0 }],
			    strokeColor: "#FF00FF",
			    strokeOpacity: 0,
			    strokeWeight: 0,
			    fillColor: "#F0F",
			    fillOpacity: 0.5
				});

				overlay.draw();
			});

			$(".clear-overlay").click(function(e){
				e.preventDefault();
				overlay.remove();
			});

			$(".save-overlay").click(function(e){
				e.preventDefault();
				var name = $(this).siblings("input[name='name']").val();
				if ( name == "" ){
					alert("Please provide a name for this overlay");
					return false;
				}
				else {
					overlay.name = name;
					self.overlays.save(overlay);
				}
			});

		},

		save : function(overlay){
			self.loader.start();

			var data = {
				name : overlay.name,
				layer_id : overlay.data.layer_id
			};

			$.post("/api/overlays/create", data,
				function(data) {
					overlay.id = data.id;

					var points = overlay.data.points;

					for ( var index in points ) {
						points[index].overlay_id = overlay.id;
					}

					$.post("/api/points/create", { points: points },
						function(response) {
							self.loader.stop();
						}
					);
				}
			);
		},

		remove : function(overlay){

		}

	};




//

	self.loader = {

		start : function(){
			$loading.fadeIn(fxspeed);
		},

		stop : function(){
			$loading.delay(500).fadeOut(fxspeed);
		}

	};

//




// self.map.canvas.setOptions({ draggableCursor: 'crosshair' });
// 
// self.data.paths = [];		
// self.data.points = [];
// 
// google.maps.event.addListener(self.map.canvas, 'click', function(mdEvent) {
// 
// 	google.maps.event.addListener(self.map.canvas, 'mousemove', function(event) {
// 		self.addPoint({ lat: event.latLng.lat(), lng: event.latLng.lng() });
//   });
// 
// 	google.maps.event.addListener(self.map.canvas, 'click', function(event) {
// 		google.maps.event.clearListeners(self.map.canvas);
// 		google.maps.event.clearListeners(self.polygon);				
//   });
// 
// 	google.maps.event.addListener(self.polygon, 'mousemove', function(event) {
// 		self.addPoint({ lat: event.latLng.lat(), lng: event.latLng.lng() });
//   });
// 
// 	google.maps.event.addListener(self.polygon, 'click', function(event) {
// 		google.maps.event.clearListeners(map.canvas);
// 		google.maps.event.clearListeners(self.polygon);				
//   });
// 
// });
















	return self.initialize();
};