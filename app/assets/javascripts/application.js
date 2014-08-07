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

$(document).ready(function() {
	$(".status-label").tooltip();

	if(window.location.pathname == "/overview"){
		$("#from_date").datepicker({
			dateFormat: "yy-mm-dd"
		});
		$("#to_date").datepicker({
			dateFormat: "yy-mm-dd"
		});
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
	if(window.location.pathname == "/rooms/new"){
		$("#room_room_type_id").change(function(){
			var data = {}
			var type = $(this).val()
			$.ajax({
				type: "get",
				dataType: "json",
				url: "/rates/search/"+type,
				data: data,
				success: function(data){
					if(data == null){
						data = {}
						$.ajax({
							type: "get",
				      dataType: "json",
				      url: "/room_types/"+type,
				      data: data,
				      success: function(data){
				      	$("#room_price").val(data)
				      }
						})
					}
					else{
						$("#room_price").val(data["price"])
					}
				}
			})
		})
	}
});
