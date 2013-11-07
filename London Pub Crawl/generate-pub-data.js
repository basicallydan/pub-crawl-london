#!/usr/bin/env node

var stations = require('./tfl-tube-data.json').stations;
var station;
var promises = [];
var Q = require('q');
var request = require('request');
var stationPubs = {};
var program = require('commander');
var successful = 0;
var failed = 0;
var fs = require('fs');

program
	.version('0.0.1')
	.option('-i, --clientId <id>', 'A foursquare API client id')
	.option('-s, --clientSecret <secret>', 'A foursquare API client secret')
	.parse(process.argv);

console.log('Using ' + program.clientId + ' and ' + program.clientSecret + ' for foursquare');

var getPubsForStation = function (station) {
	var d = Q.defer();
	console.log('Getting pubs for ' + station.name);
	request({ url : 'https://api.foursquare.com/v2/venues/explore?ll=' + station.lat + ',' + station.lng + '&client_id=' + program.clientId + '&client_secret=' + program.clientSecret + '&v=20131015&limit=3&intent=match&radius=3000&section=drinks&sortByDistance=1', json : true },
		function (err, response, body) {
			if (err) {
				console.log('Something went wrong trying to get pubs for ' + station.name);
				failed++;
				return d.resolve();
			}

			var places = [];

			if (body.response && body.response.groups && body.response.groups[0] && body.response.groups[0].items && body.response.groups[0].items.length > 0) {
				console.log('Places: ' + JSON.stringify(body.response.groups[0].items, null, 4));

				try {
					body.response.groups[0].items.forEach(function (place) {
						var placeToStore = {
							foursquareId: place.venue.id,
							name: place.venue.name,
							location: {
								address: place.venue.location.address,
								postcode: place.venue.location.postalCode,
								distance: place.venue.location.distance,
								lat: place.venue.location.lat,
								lng: place.venue.location.lng
							},
							price: place.venue.price,
							likes: {
								count: place.venue.likes.count
							}
						};

						if (place.tips && place.tips.length > 0) {
							placeToStore.tips = [];
							place.tips.forEach(function (tip) {
								placeToStore.tips.push({
									foursquareId: tip.id,
									text: tip.text,
									user: tip.user.firstName,
									created: tip.createdAt
								});
							});
						}

						places.push(placeToStore);
					});

					stationPubs[station.code] = places;
				} catch (e) {
					console.log('Oops! Something wrong in parsing: ', e);
					failed++;
					successful--;
				}

				successful++;
			} else {
				console.log('Could not find any groups in this body: ', JSON.stringify(body, null, 4));
				failed++;
			}

			d.resolve();
		}
	);
	return d.promise;
};

var lim = 10;
var num = 0;

for (station in stations) {
	// if (num < lim) {
		promises.push(getPubsForStation(stations[station]));
	// 	num++;
	// }
}

Q.allSettled(promises)
.then(function () {
	console.log('All good. Writing to file.');

	var outputFilename = './station-pubs.json';

	fs.writeFile(outputFilename, JSON.stringify(stationPubs, null, 4), function(err) {
		if (err) {
			console.log(err);
		} else {
			console.log("JSON saved to ./station-pubs.json");
			console.log(failed + '/' + (failed + successful) + ' searches failed, and ' + successful + '/' + (failed + successful) + ' were successful. Good jorb!');
		}
	});
});