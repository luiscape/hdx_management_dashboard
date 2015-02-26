function graphForecast(key, div_id,verbose) {
    url = "https://api.forecast.io/forecast/" + key + "/40.750372,-73.96941?units=si";
    $.ajax({
        url: url,
        dataType: "jsonp",
        success: function(json) {
            $("#weather-forecast-summary").text(json["hourly"]["summary"]);

            // fixing Epoch
            json["hourly"]["data"].forEach(function(d) {
                d.time = new Date(d.time * 1000);
            });

            // Filter data.
            var data, values, date_time, ind_data;
            data = new DataCollection(json["hourly"]["data"]);

            values = data.query().values("apparentTemperature");
            date_time = data.query().values("time");
            console.log(values);


            chart_data = {
                date: date_time,
                value: values
            };
            if (verbose) console.log(chart_data);

            // Generate bar chart.
            c3.generate({
                bindto: "#weather-forecast-graphic",
                data: {
                    x: 'date',
                    x_format: '%Y-%m-%dT%H:%M:%S',
                    json: chart_data,
                    type: 'bar',
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
                    pattern: ["#1abc9c"]
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
