// Browser detection for when you get desparate. A measure of last resort.
// http://rog.ie/post/9089341529/html5boilerplatejs

// var b = document.documentElement;
// b.setAttribute('data-useragent',  navigator.userAgent);
// b.setAttribute('data-platform', navigator.platform);

// sample CSS: html[data-useragent*='Chrome/13.0'] { ... }


// remap jQuery to $
(function($){

	/* trigger when page is ready */
	$(document).ready(function (){

		$(".searchButton").css("display", "none");

		$(".period").click(function(){
			window.location.href = "/reservation_statements?from_date="+$("#selectperiod").val()
		})

		$(".arriv_search").click(function(){
			window.location.href = "/arrivals?search_date="+$("#search_date").val()
		})
		$("#month").change(function(){
			$.cookie("month",$("#month").val());
		})
		$("#month_reserve").change(function(){
			$.cookie("month_reserve",$("#month_reserve").val());
		})
		$("#sidebarmenu1").children("li").children("a").click(function(){
			$.cookie("link",$(this).attr("class"), { path: '/' })
		})
		var flag = 0
		if(window.location.pathname != "/dashboard" || window.location.pathname != "/contact_people/new"){
			$("#sidebarmenu1 > li").each(function(){
				if($(this).children("a").hasClass($.cookie("link"))){
					$(this).children("a").addClass("active");
					$(this).append("<div class='progressbar'>&nbsp;</div>");
					flag = 1;
					$(this).siblings("li").each(function(){
						if($(this).children("a").hasClass("active")){
							$(this).children("a").removeClass("active");
						}
					})	
				}
				else{
					if(flag != 1){
						$(this).append("<div class='progressbar'>&nbsp;</div>")
					}
				}
			})
		}
		
		$('#traveler_sign_in_booking_btn').click(function() {
			var valuesToSubmit = $('#traveler_sign_in_booking').serialize();
			
			$.ajax({
        url: $('#traveler_sign_in_booking').attr('action'), //sumbits it to the given url of the form
        data: valuesToSubmit,
        type: "POST",
				dataType: "json",
				success: function (data) {
					$('#traveler_firstname').val(data.firstname);
					$('#traveler_lastname').val(data.lastname);
					$('#traveler_email').val(data.email);
					$('#email_confirm').val(data.email);
					$('#traveler_address1').val(data.address1);
					$('#traveler_city').val(data.city);
					$("#traveler_state_id").val(data.state_id);
					$("#traveler_country_id").val(data.country_id);
					$('#traveler_zip').val(data.zip);
					$('#traveler_phone_number').val(data.phone_number);
					
					$("#userdetails h5").eq(1).trigger("click");
				}
			});
		});
		
		$.fn.toggleDisabled = function(){
			return this.each(function(){
				this.disabled = !this.disabled;
			});
		};
		
		// Add Profile nav to page
		// $("#profileInfo").load("./includes/profile.inc.html");
		
		// Add photo upload dropzone
		Dropzone.options.dropzone = false;
		if ($( ".dropzone" ).length > 0) {
			$(".dropzone").dropzone();
		}
		
		// Fetching states from the country
		// $( ".country > select" ).change(function() {	
			
		// 	var country_id = $(this).val();
			
		// 	$.ajax({
		// 		url: '/fetch_states.json',
		// 		type: "POST",
		// 		dataType: "json",
		// 		data: { country_id: country_id },
		// 		success: function (data) {
		// 			$('.state > select').empty();
		// 			$(data).each(function(i, state){
		// 				$('.state > select').append('<option value="' + state.id + '">' + state.state_province + '</option>');
		// 			});
		// 		}
		// 	});
		// });
		
		// sign up page
		if ($( '.tabs' ).length > 0) {
			
			
			var $tabs = $(".tabs").tabs({
				fx : {
					opacity : 'toggle'
				}
			});
			
			
			$tabs.tabs({
				activate: function() {
					var progVal = ($tabs.tabs( "option", "active" )+1)*20;
					
					$( '.tabs progress' ).val(progVal);
					$( '.tabs progress span' ).html(progVal);
					
					if ($('#progressbar').length > 0) {
						$('#progressbar').css('height', ($tabs.tabs( "option", "active" )+1)*70);
					}
			
			   		return false;
				}
			});
			
			$('.tabs .formactions a').click(function (e) {
				if($(this).hasClass('firstnext')){
					e.preventDefault();
					next1ClickValidate();
				}
				else if($(this).hasClass('secondnext')){
					e.preventDefault();
					next2ClickValidate()
				}
				else{
					$tabs.tabs('option', 'active', $tabs.tabs( "option", "active" )+1); // switch to tab
			   		return false;	
				}
			   
			});

		}
		
		// Homepage Feature Grid
		if ($( ".home" ).length > 0) {
			$("#features ul").gridster({
				widget_margins: [0, 0],
				widget_base_dimensions: [171, 171]
			}).data('gridster').disable();
		}
		
		
		if ( $( ".home" ).length > 0 ) {
			// room options on booking ui
			
			// init search pane
			var sliderHeight = "42px";
			$('#searchpane .searchpicker').css('visibility','hidden');
	
			$('#searchform').each(function () {
					var current = $(this);
					current.attr("box_h", current.height());
				}
			);
			
			$("#searchform").css("height", sliderHeight);
			$("#hotel_name").on('click',function() { openSlider() });
			$("#check-in").on("click",function() { openSlider() })
			$("#check-out").on("click",function() { openSlider() })
				
			function openSlider() {

				var open_height = $("#searchform").attr("box_h") + "px";
				if (Number(($("#searchform").css('height')).split('px')[0]) < Number(open_height.split("px")[0])){
					$("#searchform").animate({"height": open_height}, {duration: "slow" });
					$("#searchpaneui a").click(function() { closeSlider() });
					$('#searchpane .searchpicker').css('visibility','visible');
				}
			}
			
			function closeSlider() {
				$("#searchform").animate({"height": sliderHeight}, {duration: "slow" });
				// $("#searchpaneui a").click(function() { openSlider() });
				$('#searchpane .searchpicker').css('visibility','hidden');
				$( '.groupopts' ).hide();
			}
		
			// init date range pickers	
			if ($('.datepicker1').length > 0) {
				var today = new Date();
				var tomorrow = new Date(today.getTime() + (24 * 60 * 60 * 1000));
				$('.datepicker1').attr("value", today.getFullYear() +'-'+ ("0" + (today.getMonth() + 1)).slice(-2) +'-'+ ("0" + today.getDate()).slice(-2) +" to " + tomorrow.getFullYear() +'-'+ ("0" + (tomorrow.getMonth() + 1)).slice(-2) +'-'+ ("0" + tomorrow.getDate()).slice(-2))
				
				// set date for today
				
				var days = new Array('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
				var months = new Array('January','February','March','April','May','June','July','August','September','October','November','December');
				var dates = new Array('1st','2nd','3rd','4th','5th','6th','7th','8th','9th','10th','11th','12th','13th','14th','15th','16th','17th','18th','19th','20th','21st','22nd','23rd','24th','25th','26th','27th','28th','29th','30th','31st');
								
				$('#checkindat').val( today.getFullYear() +'-'+ ("0" + (today.getMonth() + 1)).slice(-2) +'-'+ ("0" + today.getDate()).slice(-2) );
				$('#checkoutdate').val( tomorrow.getFullYear() +'-'+ ("0" + (tomorrow.getMonth() + 1)).slice(-2) +'-'+ ("0" + tomorrow.getDate()).slice(-2) );
				
				$(".intime").val(days[today.getDay()]+','+dates[(today.getDate()) - 1]+","+ months[today.getMonth()])
				$(".outtime").val(days[tomorrow.getDay()]+','+dates[(tomorrow.getDate()) - 1]+","+ months[tomorrow.getMonth()])
								
				$('.datepicker1').dateRangePicker({
						dayGap: 2,
						startDate: today,
						separator : ' to ',
						getValue: function(){
							if($(".intime").val() && $(".outtime").val())
								return $('.intime').val() + ' to ' + $('.outtime').val();
							else
								return '';
						},
						setValue: function(s,s1,s2){
							$('.intime').val(s1);
							$('.outtime').val(s2);
						},
						showShortcuts: false,
					
				}).bind('datepicker-change',function(event,obj){
					var oneDay = 24*60*60*1000; // hours*minutes*seconds*milliseconds
					var diffDays = Math.round(Math.abs((obj.date2.getTime() - obj.date1.getTime())/(oneDay)));
					$(this).parent().parent().prevAll('.checkindate').html('<span>Check in</span><span>' + days[obj.date1.getDay()] + ', </span><span>' + dates[(obj.date1.getDate()-1)] + '</span><br><span>' + months[obj.date1.getMonth()] + ' ' + obj.date1.getFullYear() + '</span>');
					$(this).parent().parent().prevAll('.checkoutdate').html('<span>Check out</span><span>' + days[obj.date2.getDay()] + ', </span><span>' + dates[(obj.date2.getDate()-1)] + '</span><br><span>' + months[obj.date2.getMonth()] + ' ' + obj.date2.getFullYear() + '</span>');
					$("#checkindate").val(obj.value.substr(0,obj.value.indexOf("to")));
					$("#checkoutdate").val(obj.value.substr(obj.value.indexOf("to")+2));
					$("#night-number").html(diffDays)
					$(".searchButton").css("display", "inline");
					$('.intime').val(days[obj.date1.getDay()] + ',' + dates[(obj.date1.getDate()-1)] + ',' + months[obj.date1.getMonth()]);
					$('.outtime').val(days[obj.date2.getDay()] + ',' + dates[(obj.date2.getDate()-1)] + ',' + months[obj.date2.getMonth()]);
					var lastTo = obj.value.lastIndexOf("to") 
					$.cookie("intime", obj.value.substr(0,lastTo-1))
					$.cookie("outtime", obj.value.substr(lastTo+2))
				});


				// $('.datepicker1').data('dateRangePicker').setDateRange('2014-06-03', "2014-06-04");
				
				$('.datepicker1').click();
				
			}
		}

		if(window.location.pathname == "/arrivals"){
			$("#links a:first-child").css("color", "#969696")
		}
		
		
		// home, search, bookingdetail page
		// if ( $( ".home" ).length > 0 || $( ".subpage" ).length > 0 || $( ".bookingdetail" ).length > 0) {

		
	  		
		if ($( ".bookingdetail" ).length > 0) {
			$( '#gallery' ).jGallery( {
				mode : 'standard',
				height: '400px',
				slideshowAutostart : true
			});
		}

		// CHECKOUT PAGE
		$('select#traveler_country_id').change(function(event) {
	    var country_code, select_wrapper, url;
	    select_wrapper = $('#order_state_code_wrapper');
	    $('select', select_wrapper).attr('disabled', true);
	    country_code = $(this).val();
	    url = "/home/subregion_options?parent_region=" + country_code;
	    return select_wrapper.load(url);
	  });
        
	    $('select#user_country_id').change(function(event) {
	    var country_code, select_wrapper, url;
	    select_wrapper = $('#order_state_code_wrapper');
	    $('select', select_wrapper).attr('disabled', true);
	    country_code = $(this).val();
	    url = "/users/subregion_options?parent_region=" + country_code;
	    return select_wrapper.load(url);

  	});

	    $('select#hotel_country_id').change(function(event) {
	    var country_code, select_wrapper, url;
	    select_wrapper = $('#order_state_code_wrapper');
	    $('select', select_wrapper).attr('disabled', true);
	    country_code = $(this).val();
	    url = "/hotels/subregion_options?parent_region=" + country_code;
	    return select_wrapper.load(url);

  	});


		if ($( ".checkout" ).length > 0) {
			
			$( "#bookingtotal" ).stickyfloat({
				duration : 250,
				offsetY : 185
			});
			
			$( "#userdetails" ).accordion({
				active : 1,
				heightStyle: "content"
			});
			console.log("checkout");
			$( "#roomlist" ).accordion({
				active : false,
				// collapsible : true,
				heightStyle: "content"
			});
			
			// Checkout page
			
			
		}
		
		// CHECKOUT CONFIRMATION PAGE
		
		if ($( ".checkout_confirm" ).length > 0) {
			
			$( "#bookingtotal" ).stickyfloat({
				duration : 250,
				offsetY : 185
			});
			
			$( "#roomlist" ).accordion({
				active : false,
				// collapsible : true,
				heightStyle: "content"
			});
			
		}
		
		//check availability of the hotel with checkin, checkout, roomtype and roomqty	
		$('#searchdates .check_availability').click(function () {
			var checkin = $('#checkindate').val();
			var checkout = $('#checkoutdate').val();
			var roomtype = $('#roomtypes li.selected').val();
			var roomqty = $('#roomqty').val();
			
			console.log("roomtype: ");
			console.log(roomtype);
			var rooms = new Array();
			
			for(var i=0; i<roomqty; i++){
				var adult = $('#groupopts > ul > li').eq(i).find("input").eq(0).val();
				var children = $('#groupopts > ul > li').eq(i).find("input").eq(1).val();
				rooms.push([adult, children]);
			}
			
			$.ajax({
				url: '/check_availability.json',
				type: "POST",
				dataType: "json",
				data: { checkin: checkin, checkout: checkout, roomtype: roomtype, roomqty: roomqty, rooms: rooms },
				success: function (data) {
					if (data == false) {
						$('#available_notification').text("not available");
					}else {
						$('#available_notification').text("available");
					}
				}
			});
		});
		
		// SEARCH RESULTS PAGE
		
		if ($( "#searchfilters" ).length > 0) {

			$( "#searchfilters" ).stickyfloat({
				duration : 250,
				offsetY : 253
			});
			
			
			$( "#searchresultslist" ).accordion({
				active : false,
				collapsible : true,
				heightStyle: "content"
			});			
			
			
			/** star button clicked event **/			
			$('#searchfilters .checkboxes input').click(function () {
    		// star filter params
				var star_array = new Array();
    		for(var i=0; i<5; i++){
    			if($("#searchfilters .checkboxes").find("label").eq(i).attr('aria-pressed') == "true"){
    				star_array.push(i+1);
    			}	
    		}
				
				// feature filter params
				var feature_array = new Array();
    		for(var i=0; i<$(".features input").length; i++){
    			if($("#searchfilters .features").find("label").eq(i).attr('aria-pressed') == "true"){
    				feature_array.push($("#searchfilters .features").find("input").eq(i).attr('id'));
    			}	
    		}				
				
				// price filter params
				var priceMin_str = $( 'input[name="priceMin"]' ).val();
				var priceMax_str = $( 'input[name="priceMax"]' ).val();
				var priceMin = priceMin_str.substring(1, priceMin_str.length);
				var priceMax = priceMax_str.substring(1, priceMax_str.length);
    		
				$.ajax({
					url: '/hotels/search.json',
					type: "GET",
					dataType: "json",
					data: { stars: star_array, features: feature_array, prices: [priceMin, priceMax] },
					success: function (data) {
						if($(data).length == 0){
							$("#searchresultslist").empty();
						}
												
						$(data).each(function(i, hotel){
							if (i == 0){								
								$("#searchresultslist").html(ich.hotel_detail(hotel));
							}else{
								$("#searchresultslist").append(ich.hotel_detail(hotel));
							}
						});
						
						$( "#searchresultslist" ).accordion("refresh").accordion({
							active : false,
							collapsible : true,
							heightStyle: "content"
						});		
						
					}
				});				
    	});
			
			$('#searchfilters .features input').click(function () {
				// star filter params
				var star_array = new Array();
    		for(var i=0; i<5; i++){
    			if($("#searchfilters .checkboxes").find("label").eq(i).attr('aria-pressed') == "true"){
    				star_array.push(i+1);
    			}	
    		}
				
				// feature filter params
				var feature_array = new Array();
    		for(var i=0; i<$(".features input").length; i++){
    			if($("#searchfilters .features").find("label").eq(i).attr('aria-pressed') == "true"){
    				feature_array.push($("#searchfilters .features").find("input").eq(i).attr('id'));
    			}	
    		}				
				
				// price filter params
				var priceMin_str = $( 'input[name="priceMin"]' ).val();
				var priceMax_str = $( 'input[name="priceMax"]' ).val();
				var priceMin = priceMin_str.substring(1, priceMin_str.length);
				var priceMax = priceMax_str.substring(1, priceMax_str.length);
    		
				$.ajax({
					url: '/hotels/search.json',
					type: "GET",
					dataType: "json",
					data: { stars: star_array, features: feature_array, prices: [priceMin, priceMax] },
					success: function (data) {
						if($(data).length == 0){
							$("#searchresultslist").empty();
						}
						$(data).each(function(i, hotel){
							if (i == 0){
								$("#searchresultslist").html(ich.hotel_detail(hotel));
							}else{
								$("#searchresultslist").append(ich.hotel_detail(hotel));	
							}
						});
						
						$( "#searchresultslist" ).accordion("refresh").accordion({
							active : false,
							collapsible : true,
							heightStyle: "content"
						});	
					}
				});
			});
							
			$( '#searchfilters input[type="checkbox"]' ).button();
			
			$( "#slider-price" ).slider({
				range: true,
				min: 0,
				max: 1000,
				values: [ 10, 300 ],
				slide: function( event, ui ) {
					$( 'input[name="priceMin"]' ).val( "$" + ui.values[ 0 ] );
					$( 'input[name="priceMax"]' ).val( "$" + ui.values[ 1 ] );
				}
			});
			
			$( "#slider-price" ).mouseup(function() {
				// star filter params
				var star_array = new Array();
    		for(var i=0; i<5; i++){
    			if($("#searchfilters .checkboxes").find("label").eq(i).attr('aria-pressed') == "true"){
    				star_array.push(i+1);
    			}	
    		}
				
				// feature filter params
				var feature_array = new Array();
    		for(var i=0; i<$(".features input").length; i++){
    			if($("#searchfilters .features").find("label").eq(i).attr('aria-pressed') == "true"){
    				feature_array.push($("#searchfilters .features").find("input").eq(i).attr('id'));
    			}	
    		}				
				
				// price filter params
				var priceMin_str = $( 'input[name="priceMin"]' ).val();
				var priceMax_str = $( 'input[name="priceMax"]' ).val();
				var priceMin = priceMin_str.substring(1, priceMin_str.length);
				var priceMax = priceMax_str.substring(1, priceMax_str.length);
				
				$.ajax({
					url: '/hotels/search.json',
					type: "GET",
					dataType: "json",
					data: { stars: star_array, features: feature_array, prices: [priceMin, priceMax] },
					success: function (data) {
						if($(data).length == 0){
							$("#searchresultslist").empty();
						}
						$(data).each(function(i, hotel){
							if (i == 0){
								$("#searchresultslist").html(ich.hotel_detail(hotel));
							}else{
								$("#searchresultslist").append(ich.hotel_detail(hotel));	
							}
						});
						
						$( "#searchresultslist" ).accordion("refresh").accordion({
							active : false,
							collapsible : true,
							heightStyle: "content"
						});	
					}
				});
			});
			
			$('#searchfilters .search_by_name input').keypress(function(e) {
		    if(e.which == 13) {
		    	var search_name = $(this).val(); 
		    	$.ajax({
						url: '/hotels/search.json',
						type: "GET",
						dataType: "json",
						data: { search_name: search_name },
						success: function (data) {
							if($(data).length == 0){
								$("#searchresultslist").empty();
							}
							$(data).each(function(i, hotel){
								if (i == 0){
									$("#searchresultslist").html(ich.hotel_detail(hotel));
								}else{
									$("#searchresultslist").append(ich.hotel_detail(hotel));	
								}
							});
							
							$( "#searchresultslist" ).accordion("refresh").accordion({
								active : false,
								collapsible : true,
								heightStyle: "content"
							});	
						}
					});
		    }
			});
			
			$( "#slider-rating" ).slider({
				range: true,
				min: 0,
				max: 100,
				values: [ 50, 100 ],
				slide: function( event, ui ) {
					$( 'input[name="ratingMin"]' ).val( ui.values[ 0 ] + "%" );
					$( 'input[name="ratingMax"]' ).val( ui.values[ 1 ] + "%" );
				}
			});
			
			$( 'input[name="priceMin"]' ).val( "$" + $( "#slider-price" ).slider( "values", 0 ) );
			$( 'input[name="priceMax"]' ).val( "$" + $( "#slider-price" ).slider( "values", 1 ) );
			$( 'input[name="ratingMin"]' ).val( $( "#slider-rating" ).slider( "values", 0 ) + "%" );
			$( 'input[name="ratingMax"]' ).val( $( "#slider-rating" ).slider( "values", 1 ) + "%" );
		}

		//WELCOME PAGE

		$(".room_type").change(function(){
			if($(".room_type").val() == "1"){
				$(".people").attr("max", "2")
			}
			else if($(".room_type").val() == "2"){
				$(".people").attr("max", "4")	
			}
			else if($(".room_type").val() == "3"){
				$(".people").attr("max", "6")	
			}
		})
		
		
			
	});
        
        
        
	/* optional triggers
	
	$(window).load(function() {
		
	});
	
	$(window).resize(function() {
		
	});
	
	*/

})(window.jQuery);

/*
$.datepicker._defaults.onAfterUpdate = null;

var datepicker__updateDatepicker = $.datepicker._updateDatepicker;
$.datepicker._updateDatepicker = function( inst ) {
   datepicker__updateDatepicker.call( this, inst );

   var onAfterUpdate = this._get(inst, 'onAfterUpdate');
   if (onAfterUpdate)
      onAfterUpdate.apply((inst.input ? inst.input[0] : null),
         [(inst.input ? inst.input.val() : ''), inst]);
}

function scrollToAnchor(aid){
	var aTag = $("a[name='"+ aid +"']");
	$('html,body').animate({scrollTop: aTag.offset().top},'slow');
}
*/