// The Swift Programming Language
// https://docs.swift.org/swift-book

public struct Node<T: Hashable>: Hashable, CustomStringConvertible {
  public var value: T
  public var neighbors: [Edge<T>] = []

  public var description: String {
    guard !neighbors.isEmpty else { return "\(value)" }

    let neighborsDescription = neighbors.map { "\($0)" }.joined(separator: " ")
    return "\(value) -> \(neighborsDescription)"
  }

  public init(value: T) {
    self.value = value
  }

  public static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
    return lhs.value == rhs.value
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}

public struct Edge<T: Hashable>: CustomStringConvertible {
  public var neighbor: Node<T>
  public var weight: Int

  public var description: String {
    "\(neighbor.value)(\(weight))"
  }

  public init(neighbor: Node<T>, weight: Int) {
    self.neighbor = neighbor
    self.weight = weight
  }
}

public struct Graph<T: Hashable>: CustomStringConvertible {
  private var nodes: [Node<T>] = []

  public var description: String {
    nodes.map { "\($0)" }.joined(separator: "\n")
  }

  public init(nodes: [Node<T>] = [], edges: [(Node<T>, Node<T>, Int)] = []) {
    self.nodes = nodes
    for (fromNode, toNode, weight) in edges {
      if var fromNodeInGraph = self.nodes.first(where: { $0 == fromNode }) {
        connect(from: &fromNodeInGraph, to: toNode, withWeight: weight)
      }
    }
  }

  @discardableResult
  public mutating func insertNode(withValue value: T) -> Node<T> {
    let newNode = Node(value: value)
    nodes.append(newNode)
    return newNode
  }

  public mutating func connect(from node1: inout Node<T>, to node2: Node<T>, withWeight weight: Int = 1) {
    let edge = Edge(neighbor: node2, weight: weight)
    if let index = nodes.firstIndex(of: node1) {
      nodes[index].neighbors.append(edge)
      node1.neighbors = nodes[index].neighbors
    }
  }

  public func node(forValue value: T) -> Node<T>? {
    nodes.first { $0.value == value }
  }

  public mutating func removeNode(_ node: Node<T>) {
    nodes.removeAll { $0 == node }
    for index in nodes.indices {
      nodes[index].neighbors.removeAll { $0.neighbor == node }
    }
  }

  public mutating func removeEdge(from node1: Node<T>, to node2: Node<T>) {
    if let index = nodes.firstIndex(of: node1) {
      nodes[index].neighbors.removeAll { $0.neighbor == node2 }
    }
  }
}
