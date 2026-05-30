import Combine
import Foundation

/// 생성된 여행 일정을 보관하는 공유 저장소. 화면 간에 주입해 함께 쓴다.
final class TripStore {
  @Published private(set) var trips: [Trip] = []

  func add(_ trip: Trip) {
    trips.append(trip)
  }
}
