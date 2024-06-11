//
//  ContentView.swift
//  WWD24
//
//  Created by Austin Evans on 6/10/24.
//

import SwiftUI
import SwiftData

struct AddAirportForm: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @State private var name = ""
  @State private var code = ""

  var body: some View {
    NavigationStack {
      Form {
        TextField("Name", text: $name)
        TextField("Code", text: $code)
      }
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: create) {
            Text("Add")
          }
        }
      }
      .navigationTitle("New Airport")
    }
  }

  func create() {
    withAnimation {
      let newItem = Airport(code: code, name: name)
      modelContext.insert(newItem)
      dismiss()
    }
  }
}

struct AirportList: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var airports: [Airport]

  @State var isShowingAddAirport = false

  var body: some View {
    NavigationSplitView {
      List {
        ForEach(airports) { airport in
          NavigationLink {
            Form {
              Text(airport.name)
              Text(airport.code)
                .font(.caption)
            }
          } label: {
            Text(airport.name)
          }
        }
        .onDelete(perform: deleteItems)
      }
#if os(macOS)
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
      .toolbar {
#if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
#endif
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      .navigationTitle("Airports")
    } detail: {
      Text("Select an airport")
    }
    .sheet(isPresented: $isShowingAddAirport) {
      AddAirportForm()
    }
  }
  
  private func addItem() {
    isShowingAddAirport.toggle()
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(airports[index])
      }
    }
  }
}

struct SampleData: PreviewModifier {
  static func makeSharedContext() throws -> ModelContainer {
    let schema = Schema([
      Airport.self,
      Flight.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: config)
    let airports = Airport.makeSampleAirports(in: container.mainContext)
    let flights = Flight.makeSampleFlights(in: container.mainContext)
    Flight.applyRandomAirports(to: flights, using: airports, in: container.mainContext)
    return container
  }

  func body(content: Content, context: ModelContainer) -> some View {
    content.modelContainer(context)
  }
}

extension PreviewTrait where T == Preview.ViewTraits {
  @MainActor static var sampleData: Self = .modifier(SampleData())
}

#Preview(traits: .sampleData) {
  AirportList()
}
