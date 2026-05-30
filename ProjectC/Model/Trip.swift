import Foundation

/// 확정된 단일 여행: 여행지 + 기간.
nonisolated struct Trip: Hashable {
  let destination: Destination
  let startDate: Date
  let endDate: Date

  /// 여행 일수 (당일치기면 1).
  func totalDays(using calendar: Calendar) -> Int {
    let nights = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    return nights + 1
  }
}
