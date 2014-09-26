// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui-1.10.4.custom.min
//= require_tree .
//= require modernizr-2.7.0.dev
//= require prefixfree.min
//= require jquery.uniform.min
//= require dropzone
//= require functions
//= require autocomplete-rails
//= require autocomplete-rails
//= require sidebar
//= require jquery.validationEngine
//= require jquery.validationEngine-en
//= require jquery.bxslider.min
//= require jquery.remodal
//= require jquery.slides.min

$(document).ready(function() {
	$(".status-label").tooltip();

	$("#from_date").datepicker({
			dateFormat: "yy-mm-dd",
			minDate: new Date(),
			onClose: function( selectedDate ) {
        $( "#to_date" ).datepicker( "option", "minDate", selectedDate );
      }
		});
	$("#to_date").datepicker({
		dateFormat: "yy-mm-dd",
		minDate: new Date()
	});
	if(window.location.pathname == "/overview"){
		$("#find").click(function(){
			var data = {date: $("#datepicker").val()}
			$.ajax({
				type: "get",
	      dataType: "json",
	      url: "/find_room_details",
	      data: data,
	      success: function(data){
	        $.each(data["rates"],function(index,item){
	        	$("#rate"+index).html(item["rate_"+index])
	        })
	        $.each(data["booked"],function(index,item){
	        	var key = Object.keys(item)
	        	$("#booked"+key).html(item[key])
	        })
	      }
			})
		})
	}
	$(".show_hotel").click(function(){
		window.location.href = "/hotels/" + $(this).attr('hotelid');
	});

  $(".fax_content").click(function(){
	  $("#traveler_name").html($.cookie("name"))
	  $("#hotel_name").html($.cookie("hotel_name"))
	  $("#traveler_address").html($.cookie("address"))
	  $("#traveler_phone").html($.cookie("phone_number"))
	  $("#traveler_email").html($.cookie("email"))
	  $("#amount").html($.cookie("amount"))
	  $("#cardtype").html($.cookie("cardtype"))
	  $("#card_number").html($.cookie("card_number"))
	  $("#reservation_number").html($.cookie("reservation_number"))
	  $("#arrival_date").html($.cookie("arrival_date"))
	  $("#departure_date").html($.cookie("departure_date"))
	  $("#number_night").html($.cookie("number_night"))
	  $("#no_adult").html($.cookie("no_adult"))
	  $("#remarks").html($.cookie("remarks"))
	  $("#room_type").html($.cookie("room_type"))
	  $("#total_price").html($.cookie("reservation_number"))
	  $("#expiry_date").html($.cookie("credit_card_expiry_date"))
	  $("#created_at").html($.cookie("created_at"))
  })

	$(".stat").click(function(){
		var element = $(this);
		//alert($("td").index($(this)))
		if($(this).hasClass("status-closed")){
			var status = "0"
		}
		else{
			var status = "1"
		}
		var sub_type = $(this).attr("subtype");
		var room_sub_type_id = {};
		room_sub_type_id[sub_type] = "on";
		var type = $(this).attr("type")
		var room_type_id = {};
		room_type_id[type] = "on";
		var data = {"from_date": $(this).attr("date"), "to_date": $(this).attr("date"), "room_sub_type_id": room_sub_type_id, "room_id": room_type_id, "closed": status};
		$.ajax({
      type: "post",
      dataType: "json",
      url: "/update_status",
      data: data,
      success: function(data){
      	if($(element).hasClass("status-closed")){
      		if($(element).attr("prevclass") == "status-bookable"){
      			$(element).addClass("status-bookable");
      		}
      		else{
      			if($(element).attr("nxtcls") == "status-bookable"){
      				$(element).addClass("status-bookable");	
      			}
      			else{
	      			$(element).addClass("status-none");
	      			$(element).children("span").html("x");
	      			$(element).children("span").css("padding-left", "0px");
      			}
      		}
      		$(element).removeClass("status-closed");
      	}
      	else if($(element).hasClass("status-none")){
      		$(element).attr("prevclass", "status-none");
      		$(element).removeClass("status-none");
      		$(element).addClass("status-closed");
      		$(element).children("span").html("");
      		$(element).children("span").removeAttr('style');
      	}
      	else{
      		$(element).attr("prevclass", "status-bookable");
      		$(element).removeClass("status-bookable");
      		$(element).addClass("status-closed");	
      	}
      }
    })
	})

	$(".roomphotos").click(function(){
		var data = {"room_sub_type_id": $(this).attr("room-sub-type"), "hotel_id": $(this).attr("hotel")}
		$.ajax({
      type: "get",
      dataType: "json",
      url: "/get_room_info",
      data: data,
      success: function(data){
      	console.log(data)
      }
    })
	})
});
