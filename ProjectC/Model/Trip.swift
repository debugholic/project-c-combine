import Foundation

/// 확정된 단일 여행: 여행지 + 기간.
nonisolated struct Trip: Hashable {
  let id: UUID
  let destination: Destination
  let startDate: Date
  let endDate: Date

  init(id: UUID = UUID(), destination: Destination, startDate: Date, endDate: Date) {
    self.id = id
    self.destination = destination
    self.startDate = startDate
    self.endDate = endDate
  }

  /// 여행 일수 (당일치기면 1).
  func totalDays(using calendar: Calendar) -> Int {
    let nights = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    return nights + 1
  }

  /// "Tokyo · 5박 6일 (May 10 – May 15)" 형태의 요약 문구.
  func summary(using calendar: Calendar) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "MMM d"
    let total = totalDays(using: calendar)
    if total <= 1 {
      return "\(destination.name) · 당일치기 (\(formatter.string(from: startDate)))"
    }
    let range = "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
    return "\(destination.name) · \(total - 1)박 \(total)일 (\(range))"
  }
}
