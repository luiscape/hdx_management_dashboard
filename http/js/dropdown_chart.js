// creating simple selctor for choosing what apis to chart
// this will soon be improved to use selectize.js
var apiURL = "https://ds-ec2.scraperwiki.com/dnv1xak/6gemw2mellxy2t1/sql?q=Select * From Indicators";
$.getJSON(apiURL, function(data) {
  for(var i = 0; i < data.length; i++) {
    var indicator = data[i];
	var option = document.createElement("option");
	option.text = indicator["name"];
	option.value = indicator["indID"];
	document.getElementById("indicators_dropdown").appendChild(option);
   };
});

function refreshChart() {
	// code for generating a simple time series.
    // here we are querying the API and parsing the
    // results into json arrays. those arrays contain
    // the data that will be charted.
    // in this particular implementation, we pull indicator
    // data from a speficic api call then make a list.
    // we use that list to provide the user with the ability
    // to select what indictors it wants to chart.
    // this will soon be improved with selectize.js
	var indicatorsDropDown = document.getElementById("indicators_dropdown");
	var selectedIndicator = indicatorsDropDown.value;
	var indicatorName = indicatorsDropDown.options[indicatorsDropDown.selectedIndex].text;
	console.log(indicatorName);
	console.log(String(indicatorName));
	d3.json("https://ds-ec2.scraperwiki.com/dnv1xak/6gemw2mellxy2t1/sql?q=select * from Observations Where indID='" + selectedIndicator + "'", function(error, json) {
		if (error) return console.warn(error);
		data = json;

		var value, period;
		value = jsonPath.eval(data, '$..value');
		period = jsonPath.eval(data, '$..period');

		var format = d3.time.format("%Y-%m-%d");
		var years = [];
		function getDate(element) {
		   years.push(format.parse(String(element)));
		}
		period.forEach(getDate);

		var n_datasets = c3.generate({
		  	bindto: '#n_datasets',
		  	data: {
		  		x: 'year',
		  		// x_format: '%Y',
		  		json: {
			  		year: years,
		      		n_datasets: value
		  		},
		  		type: 'bar',
		  		names: {
		  			year: 'Date',
		  			n_datasets: indicatorName
		  		}
		  	},
		  	axis: {
		        x: {
		          type: 'timeseries',
		          tick: {
		          	format: '%m %d'
		          }
		        },
		        y: {
		        	show: false
		        }
		    }
         });
    });
};
