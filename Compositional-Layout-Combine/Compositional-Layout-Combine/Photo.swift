//
//  Photo.swift
//  Compositional-Layout-Combine
//
//  Created by Alex Paul on 8/25/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

struct PhotoResultsWrapper: Decodable {
  let hits: [Photo]
}

struct Photo: Decodable, Hashable {
  let id: Int
  let webformatURL: String
}
