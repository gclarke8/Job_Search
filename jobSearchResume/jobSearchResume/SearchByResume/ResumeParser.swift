//
//  ResumeParser.swift
//  jobSearchResume
//
//  Created by Genesis Clarke on 11/30/23.
//

import Foundation

class ResumeParser {
    typealias ResumeDataCompletion = (Result<Data, Error>) -> Void
    private let jobSearchAPI = JobSearchAPI() // Initialize JobSearchAPI
    var jobListings: [JobListing] = [] // Property to store job listings


    private let apiUrl = "https://ai-resume-parser-extractor.p.rapidapi.com/pdf-upload"
    private let headers = [
        "content-type": "multipart/form-data; boundary=---011000010111000001101001",
        "X-RapidAPI-Key": "a16ad6f836msh9870e8447dc1636p118328jsn7be2e27fafb9",
        "X-RapidAPI-Host": "ai-resume-parser-extractor.p.rapidapi.com"
    ]
    

    func parseResumeData(from fileURL: URL, customSchema: String, completion: @escaping ResumeDataCompletion) {
           extractResumeData(from: fileURL, customSchema: customSchema) { result in
               switch result {
               case .success(let responseData):
                   self.processResumeData(responseData, completion: completion)
               case .failure(let error):
                   print("Error extracting resume data: \(error)")
                   completion(.failure(error))
               }
           }
       }

        func processResumeData(_ responseData: Data, completion: @escaping ResumeDataCompletion) {
           do {
               let decoder = JSONDecoder()
               let resumeData = try decoder.decode(ResumeData.self, from: responseData)
               let objective = resumeData.data.content.objective
               print("Objective: \(objective)")

               let openAIService = OpenAIService.shared // Accessing the shared instance
               openAIService.sendPromptToChatGPT(message: objective) { result in
                   switch result {
                   case .success(let response):
                       self.handleChatGPTResponse(response, completion: completion)
                   case .failure(let error):
                       print("Error from ChatGPT:", error)
                       completion(.failure(error))
                   }
               }
               // Rest of your code...
           } catch {
               print("Error parsing resume data: \(error)")
               completion(.failure(error))
           }
       }

        func handleChatGPTResponse(_ response: String, completion: @escaping ResumeDataCompletion) {
           guard let url = extractJobTitleAndCreateJobSearchURL(from: response) else {
               let error = NSError(domain: "JobTitleExtractionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to extract job title from response"])
               completion(.failure(error))
               return
           }
           
           print("Search URL :", url)
           fetchJobListings(withURL: url, completion: completion)
       }
    

    func fetchJobListings(withURL url: String, completion: @escaping ResumeDataCompletion) {
        // Use the provided URL to fetch job listings
        self.jobSearchAPI.searchJobs(withURL: url) { result in
            switch result {
            case .success(let jobListingsResponse):
                // Handle the retrieved job listings
                let jobListings = jobListingsResponse.data
                print("Job Listings:")
                for jobListing in jobListings {
                    print(jobListing)
                    // Handle each job listing as needed
                }
                // Pass an indication of success, such as an empty data instance
                completion(.success(Data()))
            case .failure(let error):
                // Handle the failure case
                print("Job search failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // Function to extract the job title from the ChatGPT response and generate the job search URL
    func extractJobTitleAndCreateJobSearchURL(from response: String) -> String? {
        guard let data = response.data(using: .utf8) else {
            return nil
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

            if let choices = json?["choices"] as? [[String: Any]], let firstChoice = choices.first {
                if let message = firstChoice["message"] as? [String: Any],
                   let functionCall = message["function_call"] as? [String: Any],
                   let argumentsString = functionCall["arguments"] as? String,
                   let argumentsData = argumentsString.data(using: .utf8) {

                    let argumentsJSON = try JSONSerialization.jsonObject(with: argumentsData, options: []) as? [String: String]

                    if let jobTitle = argumentsJSON?["jobTitle"] {
                        // Generate the job search URL using the extracted job title
                        let encodedJobTitle = jobTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        let urlString = "\(jobSearchAPI.baseUrl)search?query=\(encodedJobTitle)&page=1&num_pages=1"
                        print(urlString)
                        return urlString
                    }
                }
            }
        } catch {
            print("Error parsing ChatGPT response: \(error)")
        }

        return nil
    }

    private func extractResumeData(from fileURL: URL, customSchema: String, completion: @escaping ResumeDataCompletion) {
        let boundary = "---011000010111000001101001"
        let contentType = "application/octet-stream"

        let parameters = [
            [
                "name": "customSchema",
                "value": customSchema
            ],
            [
                "name": "file",
                "fileName": fileURL.lastPathComponent,
                "contentType": contentType,
                "file": "[object File]"
            ]
        ]

        var body = Data()
        // Construct the body of the multipart form request
        for param in parameters {
            let paramName = param["name"]!
            if let fileData = getFileContent(from: fileURL) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
                body.append(fileData)
                body.append("\r\n".data(using: .utf8)!)
            } else if let paramValue = param["value"] {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(paramValue)\r\n".data(using: .utf8)!)
            }
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!) // Append closing boundary

        if let request = createRequest(with: body) {
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    if let responseData = data {
                        completion(.success(responseData))
                    } else {
                        let parsingError = NSError(domain: "ParsingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                        completion(.failure(parsingError))
                    }
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    let error = NSError(domain: "HTTPError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                    completion(.failure(error))
                }
            }
            dataTask.resume()
        }
    }

    private func getFileContent(from fileURL: URL) -> Data? {
        do {
            let fileData = try Data(contentsOf: fileURL)
            return fileData
        } catch {
            print("Error reading file: \(error.localizedDescription)")
            return nil
        }
    }

    private func createRequest(with body: Data) -> URLRequest? {
        if let url = URL(string: apiUrl) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = body
            return request
        }
        return nil
    }
    
}
