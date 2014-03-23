// /v2/venues/explore?client_id=%@&client_secret=%@&v=20131216&ll=%@,%@&section=drinks

var Interfake = require('/Users/dan/Documents/programming/nodejs/interfake');

var interfake = new Interfake({ debug: true });

var body = {
	response: {
		groups:[
			{
				items: [
					{
						venue: {
							name: 'Test Place',
							location: {
								address: '13 Thirteen Close',
								postcode: 'A13Q13',
								distance: '30',
								lat: 51.59543,
								lng: -0.24992
							},
							price: {
								tier: 3,
								message: 'Reasonable'
							}
						},
						tips: []
					}
				]
			}
		]
	}
};

interfake.get('/v2/venues/explore').body(body);
interfake.listen(3000);