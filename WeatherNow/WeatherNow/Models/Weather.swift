import Foundation

struct Weather: Codable {
    var name: String
    var weather: [WeatherDescriptions]
    var main: WeatherNumbers
}

/*
{
   "coord":{
      "lon":13.39,
      "lat":52.52
   },
   "weather":[
      {
         "id":800,
         "main":"Clear",
         "description":"clear sky",
         "icon":"01n"
      }
   ],
   "base":"stations",
   "main":{
      "temp":291.12,
      "pressure":1008,
      "humidity":82,
      "temp_min":290.15,
      "temp_max":292.15
   },
   "visibility":10000,
   "wind":{
      "speed":1.5,
      "deg":70
   },
   "clouds":{
      "all":0
   },
   "dt":1525895400,
   "sys":{
      "type":1,
      "id":4892,
      "message":0.0074,
      "country":"DE",
      "sunrise":1525835946,
      "sunset":1525891662
   },
   "id":2950159,
   "name":"Berlin",
   "cod":200
}
 */
