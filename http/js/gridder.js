$(function() { //DOM Ready
    $(".gridster > ul")
        .gridster({
            widget_margins: [10, 10],
            widget_base_dimensions: [140, 140],
            min_cols: 5
        }).data('gridster');
});


// var gridster;

// $(function(){

//   gridster = $(".gridster > ul").gridster({
//       widget_margins: [5, 5],
//       widget_base_dimensions: [100, 70]
//   }).data('gridster');

//   var widgets = [
//       ['<li id="shareorgs"></li>', 1, 2]
//   ];

//   $.each(widgets, function(i, widget){
//       gridster.add_widget.apply(gridster, widget)
//   });

// });
