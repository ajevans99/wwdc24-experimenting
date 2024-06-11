//
//  Flight.swift
//  WWD24
//
//  Created by Austin Evans on 6/10/24.
//

import Foundation
import SwiftData

@Model
final class Flight {
  let identifier: String

  @Relationship var origin: Airport?
  @Relationship var destination: Airport?

  init(identifier: String, origin: Airport? = nil, destination: Airport? = nil) {
    self.identifier = identifier
    self.origin = origin
    self.destination = destination
  }
}

extension Flight {
  static func makeSampleFlights(in context: ModelContext) -> [Flight] {
    let flights = [
      Flight(identifier: "DL756"),
      Flight(identifier: "SW4379"),
      Flight(identifier: "AA413"),
      Flight(identifier: "BA1142"),
      Flight(identifier: "AJ2002"),
      Flight(identifier: "VK807"),
      Flight(identifier: "DL444"),
    ]

    flights.forEach { context.insert($0) }
    try? context.save()

    return flights
  }

  static func applyRandomAirports(to flights: [Flight], using airports: [Airport], in context: ModelContext) {
    for flight in flights {
      flight.origin = airports.randomElement()
      if let origin = flight.origin {
        flight.destination = airports.filter { $0 != origin }.randomElement()
      }
    }

    try? context.save()
  }
}
