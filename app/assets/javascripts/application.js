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

// $(document).ready(function() {

//   // page is now ready, initialize the calendar...
//   $('#calendar').fullCalendar({
//       // put your options and callbacks here
//       now: 	new Date(),
//       eventSources: [

//         // your event source
//         {
//             url: '/overview', // use the `url` property
//             color: 'yellow',    // an option!
//             textColor: 'black'  // an option!
//         }

//         // any other sources...

//     	],
//     	eventColor: 'yellow',
//       dayClick: function(date, jsEvent, view) {

//         // alert('Clicked on: ' + date.format());

//         // alert('Coordinates: ' + jsEvent.pageX + ',' + jsEvent.pageY);

//         // alert('Current view: ' + view.name);

//         // change the day's background color just for fun
//         if($(this).hasClass("booked")){
//           $(this).css('background-color', 'red');
//           $(this).removeClass("booked");
//         }
//         else{
//           $(this).css('background-color', '#378006');
//           $(this).addClass("booked")
//         }

//     }
//   });
//   // var from_date = $.cookie("from_date").split("&")
//   // var to_date = $.cookie("to_date").split("&")
//   var nights = $.cookie("nights").split("&");
//   // alert($.cookie("nights"))
//   $(".fc-day").each(function(i){
//     // console.log(from_date[i])
//     // console.log($(this).attr("data-date"))
//   	if($.inArray($(this).attr("data-date"),nights)!= -1){
//   		$(this).addClass("booked");
//   	}
//     // if($.inArray($(this).attr("data-date"),to_date)!= -1){
//     //  $(this).addClass("booked"); 
//     // }
//   })

// });
