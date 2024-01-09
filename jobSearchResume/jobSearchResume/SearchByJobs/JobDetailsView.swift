//
//  JobDetailsView.swift
//  jobSearchDev
//
//  Created by Genesis Clarke on 11/20/23.
//

import SwiftUI
import Foundation

struct JobDetailsView: View {
    let job: JobListing // Represents a single job listing

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Display job title in a larger, bold font
                Text(job.job_title)
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 8)

                // Display employer name and job location details
                HStack(spacing: 8) {
                    Text(job.employer_name)
                        .font(.headline)

                    // Check and display job city, state, and country if available
                    if let jobCity = job.job_city {
                        if let jobState = job.job_state, let jobCountry = job.job_country {
                            Text("|| \(jobCity), \(jobState), \(jobCountry)")
                                .font(.headline)
                                .foregroundColor(.black)
                        } else {
                            Text("Location: \(jobCity)")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                    } else {
                        // If location details are not available
                        Text("Location: Not specified")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }

                // Display salary details if available
                HStack {
                    Text("Salary:")
                        .font(.headline)
                    
                    if let minSalary = job.job_min_salary, let maxSalary = job.job_max_salary {
                        Text(formatSalary(minSalary: minSalary, maxSalary: maxSalary))
                            .font(.body)
                    } else {
                        // If salary details are not available
                        Text("Salary not specified")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }

                // Display Apply button if job apply link is provided
                if let jobApplyLink = job.job_apply_link, !jobApplyLink.isEmpty {
                    Button("Apply on Site") {
                        UIApplication.shared.open(URL(string: jobApplyLink)!)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.bottom, 8)
                }

                // Display job description section
                Text("Description")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 8)

                Text(job.job_description)
                    .font(.body)
                    .lineLimit(nil) // Show full description without line limit
                    .padding(.bottom, 16)
            }
            .padding()
            .navigationTitle("Details") // Title for navigation bar
            .navigationBarTitleDisplayMode(.inline) // Display mode for navigation title
        }
    }

    // Function to format salary details
    func formatSalary(minSalary: Double, maxSalary: Double) -> String {
        return String(format: "$%.2f - $%.2f per year", minSalary, maxSalary)
    }
}

