import Combine
import Foundation

final class TripListViewModel {

  /// 저장된 여행 목록. TripStore를 구독해 미러링한다.
  @Published private(set) var trips: [Trip] = []

  private var cancellables = Set<AnyCancellable>()

  init(store: TripStore) {
    store.$trips
      .sink { [weak self] trips in self?.trips = trips }
      .store(in: &cancellables)
  }
}
