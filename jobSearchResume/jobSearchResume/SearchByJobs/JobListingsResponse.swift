//
//  JobListingsResponse.swift
//  jobSearchDev
//
//  Created by Genesis Clarke on 11/01/23.
//

import Foundation

// Codable struct to map the received JSON response data from the job listings API into Swift
struct JobListingsResponse: Codable {
    /// Status of the API response
    let status: String

    /// Unique identifier for the API request
    let request_id: String

    /// Parameters used in the API request
    let parameters: Parameters

    /// Array of job listings data
    let data: [JobListing]

    // Nested struct to represent the parameters object
    struct Parameters: Codable {
        /// Search query for job listings
        let query: String

        /// Current page number of the results
        let page: Int

        /// Total number of pages available for the search query
        let num_pages: Int
    }

    // Define the coding keys for decoding the JSON response
    private enum CodingKeys: String, CodingKey {
        case status
        case request_id
        case parameters
        case data
    }
}
