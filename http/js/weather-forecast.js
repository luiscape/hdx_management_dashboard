function graphForecast(key, div_id,verbose) {
    url = "https://api.forecast.io/forecast/" + key + "/40.750372,-73.96941?units=si";
    $.ajax({
        url: url,
        dataType: "jsonp",
        success: function(json) {
            $("#weather-forecast-summary").text(json["daily"]["summary"]);

            // fixing Epoch
            json["daily"]["data"].forEach(function(d) {
                d.time = new Date(d.time * 1000);
            });

            // Filter data.
            var data, values, date_time, ind_data;
            data = new DataCollection(json["daily"]["data"]);

            values_min = data.query().values("apparentTemperatureMin");
            values_max = data.query().values("apparentTemperatureMax");
            date_time = data.query().values("time");

            chart_data = {
                date: date_time,
                temperature_min: values_min,
                temperature_max: values_max
            };
            if (verbose) console.log(chart_data);

            // Generate bar chart.
            c3.generate({
                bindto: "#weather-forecast-graphic",
                data: {
                    x: 'date',
                    x_format: '%Y-%m-%dT%H:%M:%S',
                    json: chart_data,
                    type: 'area-spline',
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
                color: {
                    pattern: ["#1abc9c", "#c0392b"]
                },
                size: {
                    height: 100
                },
                axis: {
                    x: {
                        show: false,
                        type: 'timeseries',
                        tick: {
                            format: "%e %b %y"
                        }
                    },
                    y: {
                        show: false
                    }
                }
            });
        }
    });
};

// Calling function.
apikey = "XXX";
graphForecast(key = apikey, div_id = "#weather-forecast-summary",true);
