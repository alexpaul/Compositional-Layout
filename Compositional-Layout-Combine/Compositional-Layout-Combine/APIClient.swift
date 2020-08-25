//
//  APIClient.swift
//  Compositional-Layout-Combine
//
//  Created by Alex Paul on 8/25/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Combine

class APIClient {
  public func searchPhotos(for query: String) -> AnyPublisher<[Photo], Error> {
    // "fish%20tacos"
    let perPage = 200 // max 200
    let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "paris"
    let endpoint = "https://pixabay.com/api/?key=\(Config.apikey)&q=\(query)&per_page=\(perPage)&safesearch=true"
    
    let url = URL(string: endpoint)!
    
    // using Combine for networking
    return URLSession.shared.dataTaskPublisher(for: url)
      .map(\.data) // data
      .decode(type: PhotoResultsWrapper.self, decoder: JSONDecoder())
      .map { $0.hits }
      .receive(on: DispatchQueue.main) // on the main thread
      .eraseToAnyPublisher()
  }
  
}
