//
//  jobSearchAPI.swift
//  jobSearchDev
//
//  Created by Genesis Clarke on 11/01/23.
//

import Foundation

class JobSearchAPI {
    
    // From Rapid API
    //https://rapidapi.com/letscrape-6bRBa3QguO5/api/jsearch/
//    import Foundation
//
//    let headers = [
//        "X-RapidAPI-Key": "a16ad6f836msh9870e8447dc1636p118328jsn7be2e27fafb9",
//        "X-RapidAPI-Host": "jsearch.p.rapidapi.com"
//    ]
//
//    let request = NSMutableURLRequest(url: NSURL(string: "https://jsearch.p.rapidapi.com/search?query=Python%20developer%20in%20Texas%2C%20USA&page=1&num_pages=1")! as URL,
//                                            cachePolicy: .useProtocolCachePolicy,
//                                        timeoutInterval: 10.0)
//    request.httpMethod = "GET"
//    request.allHTTPHeaderFields = headers
//
//    let session = URLSession.shared
//    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//        if (error != nil) {
//            print(error as Any)
//        } else {
//            let httpResponse = response as? HTTPURLResponse
//            print(httpResponse)
//        }
//    })
//
//    dataTask.resume()
    
    //----------------------------
    //  base URL for API requests
    let baseUrl = "https://jsearch.p.rapidapi.com/"
    //  API key for authorization
    let apiKey = "a16ad6f836msh9870e8447dc1636p118328jsn7be2e27fafb9"

    // Function to perform a job search using the provided URL string
    func searchJobs(withURL urlString: String, completion: @escaping (Result<JobListingsResponse, Error>) -> Void) {

        // 1st, Check if the provided URL string is valid
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        // Create a URL request using the provided URL
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Set the necessary HTTP headers for the API request
        request.allHTTPHeaderFields = [
            "X-RapidAPI-Key": apiKey,
            "X-RapidAPI-Host": "jsearch.p.rapidapi.com"
        ]

        // Create a URLSession data task to perform the API request
        URLSession.shared.dataTask(with: request) { (data, response, error) in

            // Check if there were any errors during the network request
            if let error = error {
                completion(.failure(error))
                return
            }

            // Check if the HTTP response status code is successful (200-299 range)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            // Check if there is any data received from the API response
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            // Try to decode the JSON data into a JobListingsResponse object
            do {
                let jobListingsResponse = try JSONDecoder().decode(JobListingsResponse.self, from: data)
                completion(.success(jobListingsResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

//  to represent network-related errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
}
