//
//  Item.swift
//  WWD24
//
//  Created by Austin Evans on 6/10/24.
//

import Foundation
import SwiftData

@Model
final class Airport {
  #Unique<Airport>([\.code])
  #Index<Airport>([\.code])

  var code: String
  var name: String

  init(code: String, name: String) {
    self.code = code
    self.name = name
  }
}

extension Airport {
  static func makeSampleAirports(in context: ModelContext) -> [Airport] {
    let airports = [
      Airport(code: "LHR", name: "London Heathrow"),
      Airport(code: "CDG", name: "Paris Charles de Gaulle"),
      Airport(code: "FRA", name: "Frankfurt"),
      Airport(code: "MUC", name: "Munich"),
      Airport(code: "DUS", name: "Dusseldorf"),
      Airport(code: "HAM", name: "Hamburg"),
      Airport(code: "BER", name: "Berlin"),
      Airport(code: "MAD", name: "Madrid"),
    ]

    airports.forEach { context.insert($0) }
    try? context.save()

    return airports
  }
}
