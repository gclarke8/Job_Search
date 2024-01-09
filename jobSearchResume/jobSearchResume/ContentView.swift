//
//  ContentView.swift
//  jobSearchDev
//
//  Created by Genesis Clarke on 11/01/23.
//

import SwiftUI

// main view

struct ContentView: View {
    // Declare state variables to store job listings, search query, and API URL
    @State private var jobListings: [JobListing] = []
    @State private var query: String = ""
    @State private var apiUrl: String = ""

    // Add a state variable to store initial job titles
    @State private var initialJobTitles: [String] = []

    var body: some View {
        // Create a TabView for navigation between jobs and resume import
        TabView {
            // Jobs tab
            NavigationView {
                VStack {
                    // Search bar with query binding and API URL updates
                    SearchBar(query: $query, jobSearchAPI: JobSearchAPI()) { url in
                        self.apiUrl = url
                        searchJobs() // Trigger job search when the URL changes
                    }

                    // Display the list of job listings
                    JobListingListView(jobListings: jobListings, query: query)
                }
                .navigationTitle("Job Search")
            }
            .tabItem {
                Label("Jobs", systemImage: "briefcase.fill")
            }
            UploadFile()
            // Resume import tab
            .tabItem {
                Label("Import Resume", systemImage: "doc.text.fill")
            }
        }
    }

    private func searchJobs() {
        // Check if the API URL is empty
        guard !apiUrl.isEmpty else {
            print("Query is EMPTY!")
            return // Don't perform search if the URL is empty
        }

        // Create a JobSearchAPI instance and perform the search
        let jobSearchAPI = JobSearchAPI()
        jobSearchAPI.searchJobs(withURL: apiUrl) { result in
            switch result {
            case .success(let jobListingsResponse):
                // Update the job listings on the main thread
                DispatchQueue.main.async {
                    self.jobListings = jobListingsResponse.data
                    print("Response Data:")
                    print(self.jobListings)
                }

            case .failure(let error):
                print("Error fetching job listings:", error)
            }
        }
    }
}
