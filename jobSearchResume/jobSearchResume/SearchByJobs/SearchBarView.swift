//
//  SearchBar.swift
//  jobSearchDev
//
//  Created by Genesis Clarke on 11/01/23.
//

import Foundation
import SwiftUI
struct SearchBar: View {
    @Binding var query: String// user input
    var jobSearchAPI: JobSearchAPI // instances of api
    var onSearch: (String) -> Void // pass back the generated url
    @State private var selectedFilters: Set<String> = [] // filters for refining search query
    
    //  filter options
    // each will add one to the end of the search uqery.
    let filterOptions = [
        "All Postings",
        "Posted Today",
        "Past 3 Days",
        "Remote Jobs Only",
        "Past Month",
        "Past Week",
        "Full Time",
        "Part Time",
        "Contractor",
        "Intern",
        "No Degree",
        "Under 3 Years Experience",
        "More Than 3 Years Experience",
        "No Experience"
    ]
    
    // SEARCH BAR VIEW
    var body: some View {
        VStack {
            HStack {
                // search bar
                TextField("Job title, keywords, company, or location", text: $query)
                    .padding(10)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                
                // search button passes the url back
                Button(action: {
                    let searchURL = createURLFromFilters()
                    onSearch(searchURL) // Pass the generated URL back via closure
                    
                }) {
                    Text("Search")
                        .padding(10)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                }
            }
            .padding()
            
            // CREATE THE FILTERS (TOGGLES/BUTTONS(
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(filterOptions, id: \.self) { option in
                        Button(action: {
                            toggleFilter(option)
                            let searchURL = createURLFromFilters()
                            onSearch(searchURL) // Pass the generated URL back via closure
                        }) {
                            Text(option)
                                .padding(8)
                                .foregroundColor(.black)
                                .background(selectedFilters.contains(option) ? Color.blue : Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 2)
                                        .cornerRadius(20)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(25)
            }
        }
    }
    
    
    private func toggleFilter(_ option: String) {
        if selectedFilters.contains(option) {
            selectedFilters.remove(option)
        } else {
            selectedFilters.insert(option)
        }
    }
    
//    THE API URL
//    Can add more or less pages,Number of pages to return, starting from page.
//    Allowed values: 1-20.
//    Default: 1.

//    Note: requests for more than one page and up to 10 pages are charged x2 and requests for more than 10 pages are charged 3x
    private func createURLFromFilters() -> String {
        var urlString = "\(jobSearchAPI.baseUrl)search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=1&num_pages=5"
        
        for filter in selectedFilters {
            // Depending on what filter is clicked it will add it to the add of the URL
            switch filter {
            case "Posted Today":
                urlString += "&date_posted=today"
            case "Past 3 Days":
                urlString += "&date_posted=3days"
            case "Past Week":
                urlString += "&date_posted=week"
            case "Past Month":
                urlString += "&date_posted=month"
            case "Remote Jobs Only":
                urlString += "&remote_jobs_only=true"
            case "Full Time":
                urlString += "&employment_types=FULLTIME"
            case "Part Time":
                urlString += "&employment_types=PARTTIME"
            case "Contractor":
                urlString += "&employment_types=CONRACTOR"
            case "Intern":
                urlString += "&employment_types=INTERN"
            case"No Degree":
                urlString += "&no_degree"
            case "Under 3 Years Experience":
                urlString += "&job_requirements=under_3_years_experience"
            case "More Than 3 Years Experience":
                urlString += "&job_requirements=more_than_3_years_experience"
            case"No Experience":
                urlString += "&job_requirements=no_experience"
            // defult will be query
            default:
                break
            }
        }
        // return the string to use
        return urlString
    }
}

