//
//  UploadFile.swift
//  jobSearchResume
//
//  Created by Genesis Clarke on 11/30/23.
//

import SwiftUI
import Foundation
//struct ContentView : View {
//@State private var presentImporter = false
//
//var body: some View {
//    Button("Open") {
//        presentImporter = true
//    }.fileImporter(isPresented: $presentImporter, allowedContentTypes: [.pdf]) { result in
//        switch result {
//        case .success(let url):
//            print(url)
//            //use `url.startAccessingSecurityScopedResource()` if you are going to read the data
//        case .failure(let error):
//            print(error)
//        }
//    }
//}
//}



struct UploadFile: View {
    @State private var presentImporter = false
    @State private var selectedFileURL: URL?
    @State private var jobListings: [JobListing] = []
    
    let resumeParser = ResumeParser() // Single instance of ResumeParser
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Open") {
                    presentImporter = true
                }
                .fileImporter(isPresented: $presentImporter, allowedContentTypes: [.pdf]) { result in
                    if case .success(let url) = result {
                        selectedFileURL = url
                        parseUploadedFile(at: url)
                        print("success ")
                    }
                }
                
                // Display selected file info
                if let fileURL = selectedFileURL {
                    Text("Selected File: \(fileURL.lastPathComponent)")
                        .padding()
                } else {
                    Text("No file selected")
                        .padding()
                }
                
                // Display job listings fetched from parsing the uploaded file
                if !jobListings.isEmpty {
                    List(jobListings) { jobListing in
                        // Display job listings
                    }
                }
            }
            .navigationBarTitle("Upload File")
        }
    }
    
    // Function to parse the uploaded file using ResumeParser
    private func parseUploadedFile(at fileURL: URL) {
        let customSchema = """
            {
                custom schema
            }
            """

        resumeParser.parseResumeData(from: fileURL, customSchema: customSchema) { result in
            switch result {
            case .success(let responseData):
                let jsonString = String(data: responseData, encoding: .utf8)
                print("Received JSON data:", jsonString ?? "Unable to convert data to string")

                do {
                    let jobListingsResponse = try JSONDecoder().decode(JobListingsResponse.self, from: responseData)
                    DispatchQueue.main.async {
                        jobListings = jobListingsResponse.data // Update jobListings
                    }
                } catch {
                    print("Error decoding job listings response from upload file: \(error.localizedDescription)")
                    // Handle decoding error
                }
            case .failure(let error):
                print("Error parsing resume: \(error.localizedDescription)")
                // Handle error accordingly
            }
        }
    }

}

// Your SwiftUI view that displays job listings
struct JobListingView: View {
    @State private var jobListings: [JobListing] = [] // Hold the fetched job listings
    
    var body: some View {
        VStack {
            // Display job listings fetched from the API
            if jobListings.isEmpty {
                Text("Loading...") // Show loading indicator if no data yet
            } else {
                List(jobListings, id: \.id) { job in
                    VStack(alignment: .leading) {
                        Text(job.job_title)
                            .font(.headline)
                        Text(job.employer_name)
                            .font(.subheadline)
                        // Display other job details as needed
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            // Fetch job listings when the view appears
            fetchJobListings()
        }
        .navigationTitle("Job Listings")
    }
    
    // Function to fetch job listings from the API
    private func fetchJobListings() {
        guard let url = URL(string: "https://jsearch.p.rapidapi.com/search?query=Software%20Developer&page=1&num_pages=1") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle response and update jobListings
            // This part of code is a placeholder for fetching job listings
        }.resume()
    }
}


