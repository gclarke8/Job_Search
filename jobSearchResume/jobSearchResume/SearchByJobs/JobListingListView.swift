//
//  JobListingListView.swift
//  jobSearchDev
//
//  Created by Genesis Clarke on 11/01/23.
//


import Foundation
import SwiftUI



// A VIEW for the job listings

struct JobListingListView: View {
    // An array of job listings data
    let jobListings: [JobListing]
    //  search query string
    let query: String
    @State private var isLoading = false
    
    var body: some View {
        // Use a navigation view to manage navigation between views
        NavigationView {
            // Show an empty search view if the query is empty
            if query.isEmpty {
                EmptySearchView()
            } else {
                // Display a list of job listings
                List(jobListings) { jobListing in
                    // Navigate to the job details view when a job listing is clicked
                    NavigationLink(destination: JobDetailsView(job: jobListing)) {
                        // Display a row for each job listing
                        JobListingRow(jobListing: jobListing)
                    }
                }
                .navigationBarTitle(
                    // Set the navigation bar title based on the search query
                    query.isEmpty ? "Top Results" : "Results for: \(query)"
                )
                .navigationBarTitleDisplayMode(.inline) // Display the title inline
                .navigationBarItems(trailing: EmptyView()) // Remove any trailing navigation items
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use stack navigation style to preserve smaller titles on navigation
    }
}

//  row in the list of job listings
struct JobListingRow: View {
    // The job listing data for this row
    let jobListing: JobListing

    var body: some View {
        // Use a horizontal stack to layout the job listing details
        HStack(spacing: 10) {
            // Asynchronously display the employer logo using AsyncImage
            EmployerLogoView(imageURL: URL(string: jobListing.employer_logo ?? ""))

            // Use a vertical stack to layout the job listing text
            VStack(alignment: .leading, spacing: 5) {
                // Display the job title
                Text(jobListing.job_title)
                    .font(.headline)

                // Display the employer name
                Text(jobListing.employer_name)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Display the job location
                if let jobCity = jobListing.job_city {
                    locationText(jobCity: jobCity)
                } else {
                    // Display a placeholder message if the job location is not available
                    Text("Location: Not specified")
                        .font(.body)
                        .foregroundColor(.gray)
                }

                // Display the job posting date
                if let date = jobListing.job_posted_at_datetime_utc {
                    // Format the date and display it
                    let formattedDate = formatDate(dateString: date)
                    Text(formattedDate)
                        .font(.body)
                        .foregroundColor(.gray)
                } else {
                    // Display a placeholder message if the job posting date is not available
                    Text("No Date")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding() // Add padding to the job listing row
    }

    // A function to format the job posting date
    // Cecause the date in the json responce has date as 2023-02-11 00:00:00
    
    private func formatDate(dateString: String) -> String {
        // Create date formatters
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM/dd/yyyy"

        // Parse the input date string
        if let date = dateFormatter.date(from: dateString) {
            // Format the date and return the formatted string
            return outputFormatter.string(from: date)
        } else {
            // Return an error message if the date could not be parsed
            return "Invalid Date"
        }
    }

    
    // A function to generate the job location text
    private func locationText(jobCity: String) -> some View {
        // Initialize the location text
        var locationText = "Location: \(jobCity)"

        // Append the job state and country if available
        if let jobState = jobListing.job_state, let jobCountry = jobListing.job_country {
            locationText += ", \(jobState), \(jobCountry)"
        }

        // Return the formatted location text
        return Text(locationText)
            .font(.body)
            .foregroundColor(.gray)
            .padding(.bottom, 5)
    }
}

// Displays the employer logo
struct EmployerLogoView: View {
    // The URL of the employer logo image
    let imageURL: URL?

    var body: some View {
        // Use an AsyncImage to display the employer logo asynchronously
        if let imageURL = imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    // Display a progress view while the image is loading
                    ProgressView()
                    
                case .success(let image):
                    // Display the image resized and in a  to a circle
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                case .failure:
                    // Display a placeholder image if the image fails to load
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)

                @unknown default:
                    // Display an empty view if an unknown error occurs
                    EmptyView()
                }
            }
        } else {
            // Display a placeholder image if the image URL is nil or invalid
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
        }
    }
}

// A struct that represents the empty search view
struct EmptySearchView: View {
    var body: some View {
        // Display a vertical stack with text elements
        VStack {
            // Display a heading message when there is no listings
            Text("Wow, no listings!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.gray)

            //  second a subheading message
            Text("Start searching for jobs!")
                .font(.headline)
                .foregroundColor(.gray)
                .padding()
        }
    }
}


