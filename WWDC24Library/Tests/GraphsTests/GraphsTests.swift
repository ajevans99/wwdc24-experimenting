import Testing
@testable import Graphs

struct GraphsTests {
  @Test func insertNode() {
    var graph = Graph<Int>()
    let node1 = graph.insertNode(withValue: 1)

    #expect(graph.node(forValue: 1)?.value == 1)
    #expect(node1.value == 1)
  }

  @Test func connectNodes() throws {
    var graph = Graph<String>()

    var nodeA = graph.insertNode(withValue: "A")
    let nodeB = graph.insertNode(withValue: "B")

    graph.connect(from: &nodeA, to: nodeB, withWeight: 2)

    let neighborNode = try #require(nodeA.neighbors.first)
    #expect(nodeA.neighbors.count == 1)
    #expect(neighborNode.neighbor.value == "B")
    #expect(neighborNode.weight == 2)
  }

  @Test("Ensure description on graph with both `.description` and string interpolation")
  func description() {
    var graph = Graph<String>()

    var nodeA = graph.insertNode(withValue: "A")
    let nodeB = graph.insertNode(withValue: "B")
    let nodeC = graph.insertNode(withValue: "C")

    graph.connect(from: &nodeA, to: nodeB, withWeight: 2)
    graph.connect(from: &nodeA, to: nodeC, withWeight: 3)

    let expectedDescription = "A -> B(2) C(3)\nB\nC"
    #expect(graph.description == expectedDescription)
    #expect("\(graph)" == expectedDescription)
  }

  @Test func removeNode() {
    var graph = Graph<String>()

    let nodeA = graph.insertNode(withValue: "A")
    _ = graph.insertNode(withValue: "B")

    graph.removeNode(nodeA)

    #expect(graph.node(forValue: "A") == nil)
    #expect(graph.node(forValue: "B") != nil)
  }

  @Test func removeEdge() {
    var graph = Graph<String>()

    var nodeA = graph.insertNode(withValue: "A")
    let nodeB = graph.insertNode(withValue: "B")

    graph.connect(from: &nodeA, to: nodeB, withWeight: 2)
    graph.removeEdge(from: nodeA, to: nodeB)

    #expect(graph.node(forValue: "B")?.neighbors.isEmpty == true)
  }
}

struct AirportGraphsExample {
  struct Airport: Hashable {
    let code: String
    let name: String
  }

  private static let airports: [Node<Airport>] = [
    Node(value: Airport(code: "JFK", name: "John F. Kennedy International Airport")),
    Node(value: Airport(code: "LHR", name: "London Heathrow Airport")),
    Node(value: Airport(code: "CDG", name: "Charles de Gaulle Airport")),
    Node(value: Airport(code: "DTW", name: "Detroit Metropolitan Wayne County Airport"))
  ]

  var graph = Graph<Airport>(
    nodes: Self.airports,
    edges: [
      (Self.airports[0], Self.airports[1], 1),
      (Self.airports[1], Self.airports[2], 3),
      (Self.airports[1], Self.airports[3], 4),
      (Self.airports[2], Self.airports[3], 5),
    ]
  )

  @Test
  func nodes() {
    #expect(
      graph.node(forValue: Self.airports[0].value) != nil,
      "Expected to find JFK node"
    )
    #expect(
      graph.node(forValue: Self.airports[1].value) != nil,
      "Expected to find LHR node"
    )
    #expect(
      graph.node(forValue: Self.airports[2].value) != nil,
      "Expected to find CDG node"
    )
    #expect(
      graph.node(forValue: Self.airports[3].value) != nil,
      "Expected to find DTW node"
    )
  }

  @Test func edges() {
    #expect(
      graph.node(forValue: Self.airports[1].value)?.neighbors.count == 2,
      "Expected 2 neighbors for LHR"
    )
    #expect(
      graph.node(forValue: Self.airports[2].value)?.neighbors.count == 1,
      "Expected 1 neighbor for CDG"
    )
    #expect(
      graph.node(forValue: Self.airports[3].value)?.neighbors.isEmpty == true,
      "Expected 0 neighbors for DTW"
    )
  }

  @Test mutating func addNode() {
    let newAirport = Node(value: Airport(code: "SFO", name: "San Francisco International Airport"))
    graph.insertNode(withValue: newAirport.value)
    #expect(
      graph.node(forValue: newAirport.value) != nil,
      "Expected to find SFO node"
    )
  }

  @Test mutating func removeNode() {
    let removedAirport = Self.airports[2]
    graph.removeNode(removedAirport)
    #expect(
      graph.node(forValue: removedAirport.value) == nil,
      "Expected CDG node to be removed"
    )
    #expect(
      graph.node(forValue: Self.airports[1].value)?.neighbors.contains { $0.neighbor == removedAirport } == false,
      "Expected CDG to be removed from LHR's neighbors"
    )
  }

  @Test mutating func addEdge() throws {
    var jfk = try #require(graph.node(forValue: Self.airports[0].value))
    let dtw = try #require(graph.node(forValue: Self.airports[3].value))
    graph.connect(from: &jfk, to: dtw, withWeight: 2)
    #expect(
      graph.node(forValue: jfk.value)?.neighbors.contains { $0.neighbor == dtw } == true,
      "Expected DTW to be a neighbor of JFK"
    )
  }

  @Test mutating func removeEdge() throws {
    let lhr = try #require(graph.node(forValue: Self.airports[1].value))
    let cdg = try #require(graph.node(forValue: Self.airports[2].value))
    graph.removeEdge(from: lhr, to: cdg)
    #expect(
      graph.node(forValue: lhr.value)?.neighbors.contains { $0.neighbor == cdg } == false,
      "Expected CDG to be removed from LHR's neighbors"
    )
  }
}

struct ModuleGraphsExample {
  struct Module: Hashable {
    let name: String
  }

  private static let modules: [Node<Module>] = [
    Node(value: Module(name: "Core")),
    Node(value: Module(name: "UI")),
    Node(value: Module(name: "Network")),
    Node(value: Module(name: "Database"))
  ]

  var graph = Graph<Module>(
    nodes: Self.modules,
    edges: [
      (Self.modules[0], Self.modules[1], 1),  // Core -> UI
      (Self.modules[0], Self.modules[2], 1),  // Core -> Network
      (Self.modules[2], Self.modules[3], 1)   // Network -> Database
    ]
  )

  @Test(arguments: Self.modules)
  func nodes(moduleNode: Node<Module>) {
    #expect(
      graph.node(forValue: moduleNode.value) != nil,
      "Expected to find \(moduleNode.value) module"
    )
  }

  @Test(
    arguments: [
      ("Core", 2),
      ("UI", 0),
      ("Network", 1),
      ("Database", 0)
    ]
  )
  func edges(value: String, neighborsCount: Int) {
    #expect(
      graph.node(forValue: Module(name: value))?.neighbors.count == neighborsCount,
      "Expected \(neighborsCount) neighbors for \(value) module"
    )
  }

  @Test mutating func addNode() {
    let newModule = Node(value: Module(name: "Analytics"))
    graph.insertNode(withValue: newModule.value)
    #expect(
      graph.node(forValue: newModule.value) != nil,
      "Expected to find Analytics module"
    )
  }

  @Test mutating func removeNode() {
    let removedModule = Self.modules[2]
    graph.removeNode(removedModule)
    #expect(
      graph.node(forValue: removedModule.value) == nil,
      "Expected Network module to be removed"
    )
    #expect(
      graph.node(forValue: Self.modules[0].value)?.neighbors.contains { $0.neighbor == removedModule } == false,
      "Expected Network to be removed from Core's neighbors"
    )
  }

  @Test mutating func addEdge() throws {
    var core = try #require(graph.node(forValue: Self.modules[0].value))
    let database = try #require(graph.node(forValue: Self.modules[3].value))
    graph.connect(from: &core, to: database, withWeight: 1)
    #expect(
      graph.node(forValue: core.value)?.neighbors.contains { $0.neighbor == database } == true,
      "Expected Database to be a neighbor of Core"
    )
  }

  @Test mutating func removeEdge() throws {
    let network = try #require(graph.node(forValue: Self.modules[2].value))
    let database = try #require(graph.node(forValue: Self.modules[3].value))
    graph.removeEdge(from: network, to: database)
    #expect(
      graph.node(forValue: network.value)?.neighbors.contains { $0.neighbor == database } == false,
      "Expected Database to be removed from Network's neighbors"
    )
  }
}
