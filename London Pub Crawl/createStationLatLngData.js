var request = require('request');
var lineRequestURI = 'http://transportapi.com/v3/uk/tube/{line}.json?api_key=d9307fd91b0247c607e098d5effedc97&app_id=03bf8009';
var lines = ['bakerloo', 'circle', 'hammersmith', 'metropolitan', 'piccadilly', 'waterlooandcity', 'central', 'district', 'jubilee', 'northern', 'victoria', 'dlr'];
var stationData = {};
var fs = require('fs');
var done = 0;

function writeStationDataToFileIfDone() {
	if (lines.length > done) return;
	var outputFilename = './stationCoordinates' + (new Date().getTime()) + '.json';
	fs.writeFile(outputFilename, JSON.stringify(stationData, null, 4), function (err) {
		if (err) {
			console.log('No writey to filey\n', err);
		} else {
			console.log('Data written to ' + outputFilename);
		}
	});
}

lines.forEach(function (line) {
	var uri = lineRequestURI.replace('{line}', line);
	request({ url:uri, json:true}, function (err, response, body) {
		if (err) {
			return console.log('BOOM!\n', body);
		}
		
		body.forEach(function (station) {
			// console.log(station.station_code + ' is ' + station.name + ' at ' + station.latitude + ', ' + station.longitude);
			stationData[station.station_code.toUpperCase()] = [ station.latlon.x, station.latlon.y];
		});
		done += 1;
		console.log(line + ' line done');
		writeStationDataToFileIfDone();
	});
});
