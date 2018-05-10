import Foundation

class WeatherProvider {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "da90ace91c989eceb91fe0b8254c1c14"
    
    func getWeather(city: String, completionHandler: @escaping (Weather?, Error?) -> Void) {
        
        let session = URLSession.shared
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        
        let dataTask = session.dataTask(with: weatherRequestURL) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print("Error:\n\(error)")
            } else {
                let decoder = JSONDecoder()
                do {
                    let weatherInfo = try decoder.decode(Weather.self, from: data!)
                    completionHandler(weatherInfo, nil)
                } catch {
                    print("error trying to convert data to JSON")
                    print(error)
                    completionHandler(nil, error)
                }
            }
        }
        
        dataTask.resume()
    }

}
