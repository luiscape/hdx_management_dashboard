// bargraph.js
// start with the activity graph: https://scraperwiki.com/dataset/7c6jufm

// function to generate time-series
// sparklines using an API endpoint from
// HDX. this function depends on:
// -- c3.js
// -- d3.js
// -- datacollection.js (you can use jsonpath.js instead)
function generateSparkline(table_name, column_name, div_id, verbose) {

  var url = sql_endpoint + "SELECT * FROM " + table_name;
  if (verbose) console.log("The URL for the sparkline is:", url);

  d3.json(url, function(error, json) {
    if (error) return console.warn(error);

    // filtering the data
    var data, values, dates, ind_data;
    data = new DataCollection(json);

    if (column_name == "new") {
      values = data.query().filter({ new__lt: 100 }).values(column_name);
      dates = data.query().filter({ new__lt: 100 }).values('date');
    }
    if (column_name == "changed") {
      values = data.query().filter({ changed__lt: 100 }).values(column_name);
      dates = data.query().filter({ changed__lt: 100 }).values('date');
    }

    // converting strings to date objects
    var format = d3.time.format("%Y-%m-%d");
    var date_time = [];
    function getDate(element) {
       date_time.push(format.parse(String(element)));
    };

    dates.forEach(getDate)

    chart_data = { date: date_time, value: values };
    if (verbose) console.log(chart_data);

    c3.generate({
      bindto: div_id,
      data: {
        x: 'date',
        x_format : '%Y-%m-%dT%H:%M:%S',
        json: chart_data,
        type: 'line',
        labels: false,
        selection: {
          enabled: false,
          grouped: false,
          multiple: false,
        },
      },
      point: {
        show: false
      },
      legend: {
        show: false
      },
      color: { pattern: [ "#ffffff" ] },
      size: {
          height: 100
      },
      axis : {
        x : {
          show: false,
          type : 'timeseries',
          tick : {
            format : "%e %b %y"
          }
        },
        y: {
          show: false
        }
      }
    });

  });


};

// generating sparklines
// each function calls the api endpoint
// from a resource independently.
// this causes a performance issue,
// but demonstrates how each call can be made independendtly.
generateSparkline('ckan_activity_data', 'new', '#new_datasets_spark', false);
generateSparkline('ckan_activity_data', 'changed', '#edit_datasets_spark', false);