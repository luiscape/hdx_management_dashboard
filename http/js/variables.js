// Scrpt with variables
sql_endpoint = 'https://ds-ec2.scraperwiki.com/7c6jufm/bwbcvvxuynjbrx2/sql?q=';
console.log("SQL endpoit: ", sql_endpoint);

var today = new Date();
var dd = today.getDate();
var mm = today.getMonth()+1; //January is 0!
var yyyy = today.getFullYear();

if(dd<10) {
    dd='0'+dd
}

if(mm<10) {
    mm='0'+mm
}

today = yyyy + '-' + mm + '-' + dd;
console.log("Today is: " + today);