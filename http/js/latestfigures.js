// simple function to print a single value
// to an id.
function latestFigure(table_name, column_name, id, message, verbose) {
  var url = sql_endpoint + "SELECT * FROM " + table_name + " WHERE date='" + today + "'";
  var docid = document.getElementById(id);
  docid.innerHTML = ('<span>' + "loading" + '</span>');
  d3.json(url, function(err, json) {
	if (err) {
		return console.warn(err);
		docid.innerHTML = ('<span>' + "?" + '</span>');
	}
	else {
		// gets the latest element.
		data = json[0][column_name];
		if (verbose) console.log("Datasets data is: ", data);
	  	var docid = document.getElementById(id);
	  	if (!message) {
	  		docid.innerHTML = ('<span>' + data + '</span>');
	  	}
	  	else {
	  		docid.innerHTML = ('<span>' + data + '<p>' + message + '</p>' + '</span>');
	  	};
	  };
	});
};

// building parameters to print the latest data.
latestFigure("ckan_dataset_data", "number_of_datasets", "datasets");
latestFigure("ckan_dataset_data", "number_of_users", "regusers");
latestFigure("ckan_dataset_data", "number_of_organizations", "organizations");
latestFigure("twitter_friends_data", "followers", "twitter_followers", "TWITTER FOLLOWERS");
latestFigure("twitter_friends_data", "following", "twitter_following", "TWITTER FOLLOWING");