import Combine
import Foundation

final class DestinationListViewModel {

  /// 목록 출력. Combine으로 View와 바인딩한다.
  @Published private(set) var destinations: [Destination]

  init(destinations: [Destination] = Destination.samples) {
    self.destinations = destinations
  }

  func destination(at index: Int) -> Destination? {
    destinations.indices.contains(index) ? destinations[index] : nil
  }
}
