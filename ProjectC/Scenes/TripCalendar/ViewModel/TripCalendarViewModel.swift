import Combine
import Foundation

final class TripCalendarViewModel {

  let destination: Destination
  private let store: TripStore

  // MARK: - Outputs (state)

  @Published private(set) var days: [CalendarDay] = []
  @Published private(set) var currentMonth: Date
  @Published private(set) var rangeStart: Date?
  @Published private(set) var rangeEnd: Date?

  /// 선택 상태가 갱신을 마친 뒤(커밋 후) 셀 다시 그리기를 알리는 신호.
  /// `@Published`는 willSet 시점에 발행되어 구독부에서 새 값을 못 읽으므로,
  /// 상태를 모두 반영한 다음 이 신호로 reconfigure를 트리거한다.
  var selectionChanged: AnyPublisher<Void, Never> { selectionChangedSubject.eraseToAnyPublisher() }
  private let selectionChangedSubject = PassthroughSubject<Void, Never>()

  private let calendar: Calendar

  init(destination: Destination, store: TripStore, calendar: Calendar = .current, referenceDate: Date = Date()) {
    self.destination = destination
    self.store = store
    var cal = calendar
    cal.locale = Locale(identifier: "en_US")
    self.calendar = cal
    self.currentMonth = cal.startOfMonth(for: referenceDate)
    rebuildDays()
  }

  // MARK: - Outputs (derived publishers)

  var monthTitle: AnyPublisher<String, Never> {
    $currentMonth
      .map { month in
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: month)
      }
      .eraseToAnyPublisher()
  }

  var yearTitle: AnyPublisher<String, Never> {
    $currentMonth
      .map { [calendar] month in "\(calendar.component(.year, from: month))" }
      .eraseToAnyPublisher()
  }

  /// 선택한 기간으로 하단 요약 문구를 만든다.
  var summaryText: AnyPublisher<String, Never> {
    Publishers.CombineLatest($rangeStart, $rangeEnd)
      .map { [destination, calendar] start, end in
        guard let start else { return "여행 기간을 선택하세요" }
        guard let end else { return "종료일을 선택하세요" }
        return Trip(destination: destination, startDate: start, endDate: end).summary(using: calendar)
      }
      .removeDuplicates()
      .eraseToAnyPublisher()
  }

  /// 시작·종료일이 모두 정해졌을 때만 완료할 수 있다.
  var canComplete: AnyPublisher<Bool, Never> {
    Publishers.CombineLatest($rangeStart, $rangeEnd)
      .map { $0 != nil && $1 != nil }
      .eraseToAnyPublisher()
  }

  // MARK: - Inputs

  func selectDay(_ day: CalendarDay) {
    guard day.isInCurrentMonth else { return }
    let date = calendar.startOfDay(for: day.date)

    if rangeStart == nil || rangeEnd != nil {
      // 새 기간 시작 (선택 없음, 또는 이미 완성된 기간을 새로 시작).
      rangeStart = date
      rangeEnd = nil
    } else if let start = rangeStart {
      if date < start {
        rangeStart = date        // 시작일을 앞당김
      } else {
        rangeEnd = date          // date == start → 당일치기, date > start → 기간 확정
      }
    }

    selectionChangedSubject.send()
  }

  /// 선택한 기간으로 새 여행을 만들어 저장소에 추가한다.
  func complete() {
    guard let start = rangeStart, let end = rangeEnd else { return }
    store.add(Trip(destination: destination, startDate: start, endDate: end))
  }

  func goToPreviousMonth() {
    guard let prev = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
    currentMonth = prev
    rebuildDays()
  }

  func goToNextMonth() {
    guard let next = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
    currentMonth = next
    rebuildDays()
  }

  // MARK: - Cell state

  func rangeState(for day: CalendarDay) -> CalendarDayCell.RangeState {
    guard day.isInCurrentMonth, let start = rangeStart else { return .none }
    let date = calendar.startOfDay(for: day.date)

    guard let end = rangeEnd else {
      return date == start ? .single : .none
    }
    if start == end { return date == start ? .single : .none }
    if date == start { return .start }
    if date == end { return .end }
    return (date > start && date < end) ? .middle : .none
  }

  // MARK: - Days

  private func rebuildDays() {
    let startOfMonth = calendar.startOfMonth(for: currentMonth)
    guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
      days = []
      return
    }

    let firstWeekday = calendar.component(.weekday, from: startOfMonth)
    let leadingEmpty = firstWeekday - calendar.firstWeekday

    var result: [CalendarDay] = []
    let today = calendar.startOfDay(for: Date())

    for i in 0..<leadingEmpty {
      guard let date = calendar.date(byAdding: .day, value: -(leadingEmpty - i), to: startOfMonth) else { continue }
      let dayNumber = calendar.component(.day, from: date)
      result.append(CalendarDay(
        date: date,
        dayNumber: dayNumber,
        isInCurrentMonth: false,
        isToday: calendar.isDate(date, inSameDayAs: today)
      ))
    }

    for day in range {
      guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
      result.append(CalendarDay(
        date: date,
        dayNumber: day,
        isInCurrentMonth: true,
        isToday: calendar.isDate(date, inSameDayAs: today)
      ))
    }

    let trailing = max(0, 42 - result.count)
    for _ in 0..<trailing {
      guard let lastDate = result.last?.date,
            let date = calendar.date(byAdding: .day, value: 1, to: lastDate) else { continue }
      let dayNumber = calendar.component(.day, from: date)
      result.append(CalendarDay(
        date: date,
        dayNumber: dayNumber,
        isInCurrentMonth: false,
        isToday: calendar.isDate(date, inSameDayAs: today)
      ))
    }

    days = result
  }
}

private extension Calendar {
  func startOfMonth(for date: Date) -> Date {
    let components = dateComponents([.year, .month], from: date)
    return self.date(from: components) ?? date
  }
}
