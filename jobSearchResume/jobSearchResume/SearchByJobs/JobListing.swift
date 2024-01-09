//
//  jobListing.swift
//  jobSearchDev
//
//  Created by Genesis Clarke on 11/01/23.
//


import Foundation

// Struct representing a Job Listing conforming to Codable and Identifiable protocols

struct JobListing: Codable, Identifiable {
    
    // Identifier for the job listing
    let job_id: String
    
    // Properties related to the employer
    let employer_name: String
    let employer_logo: String?
    let employer_website: String?
    let employer_company_type: String?
    
    // Additional job details
    let job_publisher: String?
    let job_employment_type: String?
    let job_title: String
    let job_apply_link: String?
    let job_apply_is_direct: Bool?
    let job_apply_quality_score: Double?
    
    // Description and location details of the job
    let job_description: String
    let job_is_remote: Bool?
    let job_posted_at_datetime_utc: String?
    let job_city: String?
    let job_state: String?
    let job_country: String?
    let job_latitude: Double?
    let job_longitude: Double?
    
    // Additional job details such as benefits, links, and salary information
    let job_benefits: [String]?
    let job_google_link: String?
    let job_offer_expiration_datetime_utc: String?
    let job_required_experience: Experience?
    let job_required_skills: [String]?
    let job_required_education: Education?
    let job_experience_in_place_of_education: Bool?
    let job_min_salary: Double?
    let job_max_salary: Double?
    let job_salary_currency: String?
    let job_salary_period: String?
    
    // Additional job highlights and categorizations
    let job_highlights: Highlights?
    let job_posting_language: String?
    let job_onet_soc: String?
    let job_onet_job_zone: String?
    let job_naics_code: String?
    let job_naics_name: String?
    
    // Use job_id as a unique identifier for Identifiable protocol
    var id: String {
        return job_id
    }
    
    // Nested struct representing Experience details
    struct Experience: Codable {
        let no_experience_required: Bool?
        let required_experience_in_months: Int?
        let experience_mentioned: Bool?
        let experience_preferred: Bool?
    }
    
    // Nested struct representing Education details
    struct Education: Codable {
        let postgraduate_degree: Bool?
        let professional_certification: Bool?
        let high_school: Bool?
        let associates_degree: Bool?
        let bachelors_degree: Bool?
        let degree_mentioned: Bool?
        let degree_preferred: Bool?
        let professional_certification_mentioned: Bool?
    }
    
    // Nested struct representing Highlights including qualifications and responsibilities
    struct Highlights: Codable {
        let qualifications: [String]?
        let responsibilities: [String]?
    }
    
    // Private enumeration of CodingKeys to map properties during encoding and decoding
    private enum CodingKeys: String, CodingKey {
        // List of all properties to be encoded and decoded
        case job_id, employer_name, employer_logo, employer_website, employer_company_type
        case job_publisher, job_employment_type, job_title, job_apply_link, job_apply_is_direct, job_apply_quality_score
        case job_description, job_is_remote, job_posted_at_datetime_utc, job_city, job_state, job_country, job_latitude, job_longitude
        case job_benefits, job_google_link, job_offer_expiration_datetime_utc, job_required_experience, job_required_skills, job_required_education, job_experience_in_place_of_education
        case job_min_salary, job_max_salary, job_salary_currency, job_salary_period
        case job_highlights, job_posting_language, job_onet_soc, job_onet_job_zone, job_naics_code, job_naics_name
        // Additional coding keys for nested structs, if any
    }
}
