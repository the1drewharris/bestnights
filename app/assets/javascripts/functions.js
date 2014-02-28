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
		
		$('#traveler_sign_in_booking_btn').click(function() {
			var valuesToSubmit = $('#traveler_sign_in_booking').serialize();
			
			$.ajax({
        url: $('#traveler_sign_in_booking').attr('action'), //sumbits it to the given url of the form
        data: valuesToSubmit,
        type: "POST",
				dataType: "json",
				success: function (data) {
					console.log(data);
					$('#traveler_firstname').val(data.firstname);
					$('#traveler_lastname').val(data.lastname);
					$('#traveler_email').val(data.email);
					$('#email_confirm').val(data.email);
					$('#traveler_address1').val(data.address1);
					$('#traveler_city').val(data.city);
					$("#traveler_state_id").val(data.state_id);
					$("#traveler_country_id").val(data.country_id);
					$('#traveler_zip').val(data.zip);
					$('#traveler_phone_number').val(data.phone_number)
				}
			});
	    console.log("Clicking");
	    
		});
		
		$.fn.toggleDisabled = function(){
			return this.each(function(){
				this.disabled = !this.disabled;
			});
		};
		
		// Add Profile nav to page
		// $("#profileInfo").load("./includes/profile.inc.html");
		
		// Add photo upload dropzone
		// if ($( ".dropzone" ).length > 0) {
			// $(".dropzone").dropzone({ url: "/file/post" });
		// }
		
		
		
		// Homepage Feature Grid
		if ($( ".home" ).length > 0) {
			$("#features ul").gridster({
				widget_margins: [0, 0],
				widget_base_dimensions: [171, 171]
			});
		}
		
		
		/*
		
		if ($( "#startdate" ).length > 0) {
			$( "#startdate" ).datepicker();
		}
		if ($( "#enddate" ).length > 0) {
			$( "#enddate" ).datepicker();
		}
		
		if ($( "#searchdatescal" ).length > 0) {
			var today = new Date();
			var dd = today.getDate() + 2;
			
			$('#searchdatescal').DatePicker({
				flat: true,
				date: [ today , dd ],
				current: today,
				calendars: 2,
				mode: 'range',
				starts: 1
			});
		}
		
		*/
		
		var cur = -1, prv = -1;
		var today = new Date();
		
		//$('#jrange input').val((today.getMonth()+1) +'/'+ today.getDate() +'/'+ today.getFullYear() +' - '+ (today.getMonth()+1) +'/'+ today.getDate() +'/'+ today.getFullYear());
		
		var d1,d2;
		var daysArray = new Array('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
		var monthsArray = new Array('January','February','March','April','May','June','July','August','September','October','November','December');
		var datesArray = new Array('1st','2nd','3rd','4th','5th','6th','7th','8th','9th','10th','11th','12th','13th','14th','15th','16th','17th','18th','19th','20th','21st','22nd','23rd','24th','25th','26th','27th','28th','29th','30th','31st');
		
		$('#checkin').html('<span>Check in</span><span>' + daysArray[today.getDay()] + ', </span><span>' + datesArray[(today.getDate()-1)] + '</span><br><span>' + monthsArray[today.getMonth()] + ' ' + today.getFullYear() + '</span>');
		$('#checkout').html('<span>Check out</span><span>' + daysArray[today.getDay()] + ', </span><span>' + datesArray[(today.getDate()-1)] + '</span><br><span>' + monthsArray[today.getMonth()] + ' ' + today.getFullYear() + '</span>');

		
		
		$('#checkindate,#checkoutdate').val( today.getFullYear() +'-'+ ("0" + (today.getMonth() + 1)).slice(-2) +'-'+ ("0" + today.getDate()).slice(-2) );
								
		$('#jrange div')
		  .datepicker({
				numberOfMonths : 2,
				minDate : today,
		
				beforeShowDay: function ( date ) {return [true, ( (date.getTime() >= Math.min(prv, cur) && date.getTime() <= Math.max(prv, cur)) ? 'date-range-selected' : '')];},
		
				onSelect: function ( dateText, inst ) {
						
					prv = cur;
					cur = (new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay)).getTime();
					
					if ( prv == -1 || prv == cur ) {
						prv = cur;
						$('#jrange input').val( dateText );
						
						$('#checkindate').val( dateText.substr(6,4)+'-'+dateText.substr(0,2)+'-'+dateText.substr(3,2) );
						
						var indatestring = $('#checkindate').val();
						var indate = new Date(indatestring.substr(0,4),(parseInt(indatestring.substr(5,2))-1),indatestring.substr(8,2));
						$('#checkin').html('<span>Check in</span><span>' + daysArray[indate.getDay()] + ', </span><span>' + datesArray[(indate.getDate()-1)] + '</span><br><span>' + monthsArray[indate.getMonth()] + ' ' + indate.getFullYear() + '</span>');
												
					} else {
						
						d1 = $.datepicker.formatDate( 'yy-mm-dd', new Date(Math.min(prv,cur)), {} );
						d2 = $.datepicker.formatDate( 'yy-mm-dd', new Date(Math.max(prv,cur)), {} );
						$('#jrange input').val( d1+' : '+d2 );
						
						// drop dates into fields for form
						$('#checkindate').val( d1 );
						$('#checkoutdate').val( d2 );	
						
						var indatestring = $('#checkindate').val();
						var outdatestring = $('#checkoutdate').val();
						var indate = new Date(indatestring.substr(0,4),(parseInt(indatestring.substr(5,2))-1),indatestring.substr(8,2));
						var outdate = new Date(outdatestring.substr(0,4),(parseInt(outdatestring.substr(5,2))-1),outdatestring.substr(8,2));
						
						$('#checkin').html('<span>Check in</span><span>' + daysArray[indate.getDay()] + ', </span><span>' + datesArray[(indate.getDate()-1)] + '</span><br><span>' + monthsArray[indate.getMonth()] + ' ' + indate.getFullYear() + '</span>');	
						$('#checkout').html('<span>Check out</span><span>' + daysArray[outdate.getDay()] + ', </span><span>' + datesArray[(outdate.getDate()-1)] + '</span><br><span>' + monthsArray[outdate.getMonth()] + ' ' + outdate.getFullYear() + '</span>');					
											
					}
					
					
					
					
					
					
					// display dates for user	
					
						
										
				},
		
				onChangeMonthYear: function ( year, month, inst ) {
					  //prv = cur = -1;
				   },
		
				onAfterUpdate: function ( inst ) {
					  /*
					  $('<button type="button" class="ui-datepicker-close ui-state-default ui-priority-primary ui-corner-all" data-handler="hide" data-event="click">Done</button>')
						 .appendTo($('#jrange div .ui-datepicker-buttonpane'))
						 .on('click', function () { $('#jrange div').hide(); });
						 */
				   }
			 })
		  .position({
				my: 'left top',
				at: 'left bottom',
				of: $('#jrange input')
			 })
		  .hide();

			$('#jrange input').on('focus', function (e) {
				 
			  });
			  
		var v = this.value, d;
			
				 try {
					if ( v.indexOf(' - ') > -1 ) {
					   d = v.split(' - ');
			
					   prv = $.datepicker.parseDate( 'yy-mm-dd', d[0] ).getTime();
					   cur = $.datepicker.parseDate( 'yy-mm-dd', d[1] ).getTime();
			
					} else if ( v.length > 0 ) {
					   prv = cur = $.datepicker.parseDate( 'yy-mm-dd', v ).getTime();
					}
				 } catch ( e ) {
					cur = prv = -1;
				 }
			
				 if ( cur > -1 )
					$('#jrange div').datepicker('setDate', new Date(cur));
			
				 $('#jrange div').datepicker('refresh').show();	
				 
		
		
		$( '#roomtypes li:nth-child(1)' ).click(function(){
			$(this).toggleClass('selected');
			$('#groupopts').hide(500);
			$('#roomtypes li:nth-child(2),#roomtypes li:nth-child(3)').removeClass('selected');
			$('#roomtype').val('');
		});
		
		$( '#roomtypes li:nth-child(2)' ).click(function(){
			$(this).toggleClass( 'selected' );
			$('#groupopts').hide(500);
			$('#roomtypes li:nth-child(1),#roomtypes li:nth-child(3)').removeClass('selected');
			$('#roomtype').val('');
		});
		
		$( '#roomtypes li:nth-child(3)' ).click(function(){
			$(this).toggleClass( 'selected' );
			$('#groupopts').toggle(500);
			$('#roomtypes li:nth-child(1),#roomtypes li:nth-child(2)').removeClass('selected');
			$('#roomtype').val('');
		});
		
		$("#roomtypes li").click(function(){			
			$("#roomtype").val($(this).val());
		});
		
		var $roomcount = 1;
		var $roomchange = 0;
		
		$( '#roomqty' ).change(function(){
			console.log($('#groupopts > ul > li').length);
			if ($('#roomqty').val() > $('#groupopts > ul > li').length) {
				$roomchange = $('#roomqty').val() - $('#groupopts > ul > li').length;
				for(var i = 0; i < $roomchange; i++){
					$('#groupopts > ul').append('<li><h5>Room '+parseInt($('#groupopts > ul > li').length+1)+'</h5><ul><li><label>Adults</label><input name="group[beds]['+parseInt($('#groupopts > ul > li').length+1)+'][adultqty]" type="number" min="0" value="1"></li><li><label>Children</label><input name="group[beds]['+parseInt($('#groupopts > ul > li').length+1)+'][childqty]" type="number" min="0" value="0"></li></ul></li>');
				}
			} else if ($('#roomqty').val() < $('#groupopts > ul > li').length) {
				$roomchange = $('#groupopts > ul > li').length - $('#roomqty').val();
				for(var i = 0; i < $roomchange; i++){
					$('#groupopts > ul > li:last-child').remove();
				}
			}
			
		});
		
		
	  		
		if ($( ".bookingdetail" ).length > 0) {
			$( '#gallery' ).jGallery( {
				mode : 'standard',
				slideshowAutostart : true
			});
		}

		// CHECKOUT PAGE
		
		if ($( ".checkout" ).length > 0) {
			
			$( "#bookingtotal" ).stickyfloat({
				duration : 250,
				offsetY : 185
			});
			
			$( "#userdetails" ).accordion({
				active : 1,
				heightStyle: "content"
			});
			
			$( "#roomlist" ).accordion({
				active : false,
				collapsible : true,
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
				collapsible : true,
				heightStyle: "content"
			});
			
		}
		
			
		$('#searchdates .check_availability').click(function () {
			var checkin = $('#checkindate').val();
			var checkout = $('#checkoutdate').val();
			var roomtype = $('#roomtype').val();
			var roomqty = $('#roomqty').val();
			
			var rooms = new Array();
			
			for(var i=0; i<roomqty; i++){
				var adult = $('#groupopts > ul > li').eq(i).find("input").eq(0).val();
				var children = $('#groupopts > ul > li').eq(i).find("input").eq(1).val();
				rooms.push([adult, children]);
			}
			
			console.log(rooms);
			
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
    		var star_array = new Array();
    		for(var i=0; i<5; i++){
    			if($("#searchfilters .checkboxes").find("label").eq(i).attr('aria-pressed') == "true"){
    				star_array.push(i+1);
    			}	
    		}
    		
				$.ajax({
					url: '/hotels/search.json',
					type: "GET",
					dataType: "json",
					data: { stars: star_array },
					success: function (data) {
						if($(data).length == 0){
							console.log("empty");
							// $("#searchresultslist").remove();
						}
						
						$(data).each(function(i, hotel){
							if (i == 0){
								$("#searchresultslist").html(ich.hotel_detail(hotel));
							}else{
								$("#searchresultslist").append(ich.hotel_detail(hotel));	
							}
						});
					}
				});				
    	});
			
			$('#searchfilters .features input').click(function () {
				var feature_array = new Array();
    		for(var i=0; i<$(".features input").length; i++){
    			if($("#searchfilters .features").find("label").eq(i).attr('aria-pressed') == "true"){
    				feature_array.push($("#searchfilters .features").find("input").eq(i).attr('id'));
    			}	
    		}
    		
				$.ajax({
					url: '/hotels/search.json',
					type: "GET",
					dataType: "json",
					data: { features: feature_array },
					success: function (data) {
						if($(data).length == 0){
							console.log("empty");
							// $("#searchresultslist").remove();
						}
						$(data).each(function(i, hotel){
							if (i == 0){
								$("#searchresultslist").html(ich.hotel_detail(hotel));
							}else{
								$("#searchresultslist").append(ich.hotel_detail(hotel));	
							}
						});
					}
				});
			});
							
			$( '#searchfilters input[type="checkbox"]' ).button();
			
			$( "#slider-price" ).slider({
				range: true,
				min: 0,
				max: 1000,
				values: [ 50, 300 ],
				slide: function( event, ui ) {
					$( 'input[name="priceMin"]' ).val( "$" + ui.values[ 0 ] );
					$( 'input[name="priceMax"]' ).val( "$" + ui.values[ 1 ] );
				}
			});
			
			$( "#slider-price" ).mouseup(function() {
				var priceMin_str = $( 'input[name="priceMin"]' ).val();
				var priceMax_str = $( 'input[name="priceMax"]' ).val();
				var priceMin = priceMin_str.substring(1, priceMin_str.length);
				var priceMax = priceMax_str.substring(1, priceMax_str.length);
				
				$.ajax({
					url: '/hotels/search.json',
					type: "GET",
					dataType: "json",
					data: { prices: [priceMin, priceMax] },
					success: function (data) {
						if($(data).length == 0){
							console.log("empty");
							// $("#searchresultslist").remove();
						}
						$(data).each(function(i, hotel){
							if (i == 0){
								$("#searchresultslist").html(ich.hotel_detail(hotel));
							}else{
								$("#searchresultslist").append(ich.hotel_detail(hotel));	
							}
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
								console.log("empty");
								// $("#searchresultslist").remove();
							}
							$(data).each(function(i, hotel){
								if (i == 0){
									$("#searchresultslist").html(ich.hotel_detail(hotel));
								}else{
									$("#searchresultslist").append(ich.hotel_detail(hotel));	
								}
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