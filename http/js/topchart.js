function topChart() {
    // defining all the charted dimensions

    // defining global variables.
    var n_regusers, date_time, n_orgs;

	// date and time
	d3.json("data/regusers.json", function(error, json) {
      if (error) return console.warn(error);
	  data = jsonPath.eval(json, '$..period');

	  // converting strings to date objects
	  var format = d3.time.format("%Y-%m-%d");
	  var date_time = [];
	  function getDate(element) {
	     date_time.push(format.parse(String(element)));
	  };
	  data.forEach(getDate);
        // registered users
		d3.json("data/regusers.json", function(error, json) {
	      if (error) return console.warn(error);
		  n_regusers = jsonPath.eval(json, '$..value');
			// organizations
			d3.json("data/orgs.json", function(error, json) {
		      if (error) return console.warn(error);
			  n_orgs = jsonPath.eval(json, '$..value');

					var topchart = c3.generate({
					  	bindto: '#topchart',
					  	size: {
					  		height: 200,
					  	},
					  	data: {
					  		x: 'date',
							json: {
								date: date_time,
								users: n_regusers,
								orgs: n_orgs
							},
					  		type: 'spline',
					  		names: {
					  			date: 'Date',
					  			orgs: 'Number of Organization in CKAN',
					  			users: 'Number of Users Registered in CKAN'
					  		},
					  		selection: {
					  			enabled: true
					  		}
					  	},
					  	axis: {
					  		x: {
					  			show: false,
	          					type: 'timeseries',
	          					tick: {
	          						format: '%b %d'
	          						// rotate: 90
	          					}
	        				},
					        y: {
					        	show: false
					        }
					    },
					    point: {
					    	show: true
					    },
					    legend: {
					  		position: 'left'
					  	}
			         });
		     	});
		     });
	   });
};

function datasetChart() {
var n_datasets, date_time;
// date and time
d3.json("data/regusers.json", function(error, json) {
	if (error) return console.warn(error);
	data = jsonPath.eval(json, '$..period');

	// converting strings to date objects
	var format = d3.time.format("%Y-%m-%d");
	var date_time = [];
	function getDate(element) {
		date_time.push(format.parse(String(element)));
	};
		data.forEach(getDate);

		// datasets
		d3.json("data/datasets.json", function(error, json) {
			if (error) return console.warn(error);
				n_datasets = jsonPath.eval(json, '$..value');

    	var n_datasets_chart = c3.generate({
			  	bindto: '#n_datasets_chart',
			  	size: {
			  		height: 240,
			  	},
			  	data: {
			  		x: 'date',
					json: {
						date: date_time,
						datasets: n_datasets
					},
			  		type: 'line',
			  		names: {
			  			date: 'Date',
			  			datasets: 'Number of Datasets in CKAN'
			  		}
			  	},
			  	axis: {
			  		x: {
      					type: 'timeseries',
      					tick: {
      						format: '%Y-%m-%d'
      					},
    				},
			        y: {
			        	show: false,
			        	max: 1400,
						min: -100,
						padding: {top:0, bottom:0}
			        }
			    },
			    point: {
			    	show: true
			    },
			    legend: {
			    	show: false,
			  		position: 'right'
			  	}
	         });
		});
	});
};

// running the function
topChart();
datasetChart();