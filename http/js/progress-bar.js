d3.json('https://ds-ec2.scraperwiki.com/3grrlc8/pchhes1jjv0k8fi/sql?q=select * from crowdsourced_data', function(error, json) {
     if (error) return console.log('There was an error:' + error);
     responseData = json;

     d3.json('https://ds-ec2.scraperwiki.com/3grrlc8/pchhes1jjv0k8fi/sql?q=select%20*%20from%20cap_appeals_list', function(error, json) {
       if (error) return console.log('There was an error:' + error);
       capData = json;

       // parsing the json with jsonPath
       var capProgress;
       capProgress = jsonPath.eval(responseData, '$..docID');

       // function to count how many times
       // a document has been respondede
	   function countInArray(array, index) {
	     var count = 0;
	     for (var i = 0; i < array.length; i++) {
	        if (array[i] === index) {
	          count++;
	        }
	     }
         return count;
       }

       // creating another function for redundancy
       // and using the function above as input
       // and creating an array only with the
       // redundant ones
  	   function checkRedundancy(sourceArray, storeArray, redundancy) {
	    for (i = 0; i < sourceArray.length; i++) {
  	  	  count = countInArray(sourceArray, sourceArray[i]);
  		  if (count >= redundancy) {
  	        storeArray.push(sourceArray[i]);
  		  }
	     }
	   }


     // getting only the unique values of the array
     Array.prototype.contains = function(v) {
         for(var i = 0; i < this.length; i++) {
             if(this[i] === v) return true;
         }
         return false;
     };

     Array.prototype.unique = function() {
         var arr = [];
         for(var i = 0; i < this.length; i++) {
             if(!arr.contains(this[i])) {
                 arr.push(this[i]);
             }
         }
         return arr;
     }


     var completedListRedundant = [];
     var redundancyLevel = 3;
     checkRedundancy(capProgress, completedListRedundant, redundancyLevel);

     // getting only the unique ones
     var uniqueIDs = completedListRedundant.unique();

     // sanity check
     console.log(uniqueIDs);

     // calculating progress
     var progress = Math.ceil((uniqueIDs.length / capData.length) * 100);
     console.log('Progress: ', progress, '%');


     // filling in the progress bar
     var p = '<div class="progress-bar" style="width:' + progress + '%;"></div>'
     var doc = document.getElementById('capProgressBar');
     doc.innerHTML = p;

     // filling in the progress information
     var docFigPercentage = document.getElementById('capProgressFigurePercentage');
     docFigPercentage.innerHTML = '<strong>' + progress + '%' + '</strong>';

     var docFig = document.getElementById('capProgressFigure');
     docFig.innerHTML = '<strong>' + uniqueIDs.length + '</strong>';

  });
});
