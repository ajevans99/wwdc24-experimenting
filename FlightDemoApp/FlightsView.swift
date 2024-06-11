//
//  FlightsView.swift
//  WWD24
//
//  Created by Austin Evans on 6/10/24.
//

import SwiftUI
import SwiftData

struct FlightList: View {
  static func predicate(searchText: String) -> Predicate<Flight> {
    #Predicate<Flight> { flight in
      searchText.isEmpty ? true : flight.identifier.localizedStandardContains(searchText)
    }
  }

  @Environment(\.modelContext) private var modelContext
  @Query private var flights: [Flight]

  let searchText: String

  init(searchText: String) {
    self.searchText = searchText

    _flights = Query(filter: Self.predicate(searchText: searchText))
  }

  var body: some View {
    List {
      ForEach(flights) { flight in
        NavigationLink {

        } label: {
          VStack(alignment: .leading) {
            Text(flight.identifier)
              .font(.headline)
              .monospaced()
            HStack(alignment: .lastTextBaseline) {
              if let origin = flight.origin {
                Image(systemName: "airplane.departure")
                Text(origin.code)
              }

              Spacer()

              if let destination = flight.destination {
                Text(destination.code)
                Image(systemName: "airplane.arrival")
              }
            }
            .foregroundStyle(.secondary)
          }
        }
      }
    }
    .animation(.default, value: flights)
  }
}

struct FlightsView: View {
  @State private var searchText = ""

  var body: some View {
    NavigationSplitView {
      FlightList(searchText: searchText)
        .searchable(text: $searchText, prompt: "Find Flight")
  #if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
  #endif
        .toolbar {
  #if os(iOS)
          ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
          }
  #endif
        }
        .navigationTitle("Flights")
    } detail: {
      Text("Select a Flight")
    }
  }
}

#Preview(traits: .sampleData) {
  FlightsView()
}
