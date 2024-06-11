//
//  FlightDemoApp.swift
//  WWD24
//
//  Created by Austin Evans on 6/10/24.
//

import SwiftUI
import SwiftData

@main
struct FlightDemoApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Airport.self,
      Flight.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      TabView {
        Tab("Airports", systemImage: "airplane") {
          AirportList()
        }
        Tab("Flights", systemImage: "list.bullet.clipboard") {
          FlightsView()
        }
      }
    }
    .modelContainer(sharedModelContainer)
  }
}
