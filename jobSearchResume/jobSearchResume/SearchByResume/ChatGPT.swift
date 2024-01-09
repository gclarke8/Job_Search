//
//  ChatGPT.swift
//  jobSearchResume
//
//  Created by Genesis Clarke on 12/2/23.
//

import Foundation

enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}

struct GPTMessage: Encodable {
    let role: String
    let content: String
}

class OpenAIService {
    static let shared = OpenAIService()

    init() {}

    func generateURLRequest(httpMethod: HTTPMethod, message: String, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        do {
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                throw URLError(.badURL)
            }

            var urlRequest = URLRequest(url: url)
            // Method
            urlRequest.httpMethod = httpMethod.rawValue

            // Headers
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("Bearer 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", forHTTPHeaderField: "Authorization")

            // Body - messages you send to OpenAI
            let systemMessage = GPTMessage(role: "user", content: "You are a job title expert, you can match any objective with a job title. You choose the most relvant job title based on the sentence. Choose just one title if there is multiple options.")
            let userMessage = GPTMessage(role: "system", content: message)
            
            let objective = GPTFunctionProperty(type: "string", description: "The objective statement to convert to job title")
            let jobTitle = GPTFunctionProperty(type: "string", description: "The job title corresponding to the objective statement")
            let params: [String: GPTFunctionProperty] = [
                "objective": objective,
                "jobTitle": jobTitle
            ]
            let functionParams = GPTFunctionParam(type: "object", properties: params, required: ["objective", "jobTitle"])
            let function = GPTFunction(name: "getTitle", decription: "Get the job title based on an objective statement", parameters: functionParams)
            
            // Perform any necessary tasks with userMessage and systemMessage here
            let payload = GPTChatPayload(model: "gpt-4-1106-preview", messages: [systemMessage, userMessage], functions: [function])
            
            let jsonData = try JSONEncoder().encode(payload)
            urlRequest.httpBody = jsonData

            completion(.success(urlRequest))
        } catch {
            completion(.failure(error))
        }
        func fetchTitleFromGPT(objective: String, completion: @escaping (Result<String, Error>) -> Void) {
            generateURLRequest(httpMethod: .post, message: objective) { result in
                switch result {
                case .success(let urlRequest):
                    URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                        if let error = error {
                            completion(.failure(error))
                        } else if let data = data {
                            do {
                                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                   let choices = jsonObject["choices"] as? [[String: Any]],
                                   let choice = choices.first,
                                   let functionCall = choice["message"] as? [String: Any],
                                   let arguments = functionCall["function_call"] as? [String: Any],
                                   let jobTitle = arguments["jobTitle"] as? String {
                                    // Extract job title from functionCall arguments
                                    completion(.success(jobTitle))
                                } else {
                                    completion(.failure(NSError(domain: "ResponseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error parsing response"])))
                                }
                            } catch {
                                completion(.failure(error))
                            }
                        }
                    }.resume()
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

            }
    
    func sendPromptToChatGPT(message: String, completion: @escaping (Result<String, Error>) -> Void) {
        generateURLRequest(httpMethod: .post, message: message) { result in
            switch result {
            case .success(let urlRequest):
                URLSession.shared.dataTask(with: urlRequest) { data, _, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        completion(.success(responseString))
                    }
                }.resume()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct GPTChatPayload: Encodable {
    let model: String
    let messages: [GPTMessage]
    let functions: [GPTFunction]
}

struct GPTFunction: Encodable {
    let name: String
    let decription: String
    let parameters: GPTFunctionParam
}

struct GPTFunctionParam: Encodable {
    let type: String
    let properties: [String: GPTFunctionProperty]?
    let required: [String]?
}

struct GPTFunctionProperty: Encodable {
    let type: String
    let description: String
}

//import XCTest
//
//class OpenAIServiceTests: XCTestCase {
//    func testSendPromptToChatGPTWithObjectiveStatement() {
//        let openAIService = OpenAIService()
//        let expectation = expectation(description: "Received response from ChatGPT")
//
//        openAIService.sendPromptToChatGPT(message: "objective: i am seeking a position as a teacher in education") { result in
//            switch result {
//            case .success(let response):
//                print("Response from ChatGPT:", response)
//                // Add your assertions here based on the response if needed
//
//                expectation.fulfill()
//            case .failure(let error):
//                XCTFail("Error: \(error)")
//                expectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 5) // Adjust the timeout value as needed
//    }
//}

