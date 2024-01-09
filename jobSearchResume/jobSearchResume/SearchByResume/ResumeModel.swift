//
//  ResumeModel.swift
//  jobSearchResume
//
//  Created by Genesis Clarke on 11/30/23.
//

import Foundation

// Model for Experience data
struct Experience: Codable {
    let startDate: String
    let description: String
    let jobTitle: String
    let endDate: String?
    let company: String
}

// Model for Content data
struct ContentData: Codable {
    let content: Content
}

// Model for Content
struct Content: Codable {
    let fullName: String
    let objective: String
    let experience: [Experience]
}

// Model for Resume data
struct ResumeData: Codable {
    let jobID: String
    let data: ContentData
}
