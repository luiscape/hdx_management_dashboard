// Getting the shares.
function shareOrg(id) {
  var table_name = "ckan_organization_data";
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
		data = new DataCollection(json);
    	no_data = data.query().filter({ package_count: 0 }).values();
    	total = (no_data.length / json.length) * 100;
	  	var docid = document.getElementById(id);
		docid.innerHTML = ('<span>' + total.toFixed(1) + '%</span><p>ORGANIZATIONS</p><p>SHARING</p><p>DATA</p>');
	  };
	});
};

function shareDatasetsOrgs(id) {
  var table_name = "ckan_organization_data";
  var url = sql_endpoint + "SELECT * FROM " + table_name + " WHERE date='" + today + "'";
  var docid = document.getElementById(id);
  docid.innerHTML = ('<span>' + "loading" + '</span>');
  d3.json(url, function(err, json) {
	if (err) {
		return console.warn(err);
		docid.innerHTML = ('<span>' + "Error." + '</span>');
	}
	else {
		// gets the latest element.
		data = new DataCollection(json);
    	average = data.query().avg("package_count");
    	console.log("Average:" + average);
	  	var docid = document.getElementById(id);
		docid.innerHTML = ('<span>' + average.toFixed(0) + '</span><p>DATASETS</p><p>PER</p><p>ORGANIZATION</p>');
	  };
	});
};


shareOrg("shareorgs");
shareDatasetsOrgs("datasetsorgs");
// shareDatasetsOrgs("shareorgs");