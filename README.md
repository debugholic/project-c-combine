# Project C — Combine

[Project A-Z](#project-a-z) 의 C 단계.

단계마다 새로운 기술 스택을 하나씩 더해가며, 조금씩 다른 기능을 구현해 나갑니다.
C 단계에서는 B(UIKit + MVVM + Diffable)의 **클로저 바인딩을 Combine으로 전환**하고,
앱을 **여행 플래너**로 확장합니다 — 여행지를 고르고 달력에서 여행 기간을 지정합니다.

## 다루는 기술

- UIKit (Programmatic, Storyboard 없음)
- MVVM
- Diffable Data Source (테이블/컬렉션 양쪽)
- **Combine** (입력·출력 양방향 바인딩) ← 이번 단계 추가분

## 기능

두 단계 네비게이션 플로우의 여행 플래너입니다.

1. **여행지 선택** — 여행지 목록(이름 + 나라)에서 하나를 고릅니다.
2. **여행 기간 지정** — 선택한 여행지의 달력에서 시작일·종료일을 탭해 기간을 정하면 하단에 요약(`Tokyo · 5박 6일 (Jun 10 – Jun 15)`)이 표시됩니다.

- 기간 지정: 시작일 탭 → 종료일 탭 → 범위 하이라이트 (시작·중간·종료 구분)
- 시작일 이전 날짜 탭 시 시작일 앞당김, 기간 완성 후 새 날짜 탭 시 새로 시작, 같은 날 두 번 탭하면 당일치기

## B 단계와 달라진 점

| | B (Diffable) | C (+ Combine) |
|---|---|---|
| 바인딩 | `onUpdate` 클로저 | `@Published` / `AnyPublisher` + `sink`·`store(in:)` |
| 입력 | delegate / target-action → VM 메서드 | UIControl 이벤트 → Combine publisher → VM |
| 화면 | 단일 달력 화면 | 여행지 목록 → 달력 2단계 플로우 |
| 선택 상태 | 단일 날짜 + 메모 | 날짜 범위(start~end) + 여행지 |
| 셀 상태 | isSelected / hasMemo | 범위 상태(none/start/middle/end/single) |

핵심 아이디어: 각 ViewModel은 상태를 `@Published`로 노출하고, 요약·헤더는 `CombineLatest`/`map`으로 파생합니다.
View는 출력 publisher를 `sink`로 구독하고, 입력(버튼)은 `UIControl`을 감싼 커스텀 Combine publisher로 ViewModel에 전달합니다. 목록은 `UITableViewDiffableDataSource`, 달력은 `UICollectionViewDiffableDataSource`로 그립니다.

## 구조

```
ProjectC/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift              # 루트 = 여행지 목록
├── Extensions/
│   └── UIControl+Publisher.swift        # UIControl 이벤트 → Combine publisher
├── Model/
│   ├── Destination.swift                # 여행지 (이름 + 나라)
│   ├── CalendarDay.swift                # Hashable — diffable 식별자
│   └── Trip.swift                       # 여행지 + 기간
└── Scenes/
    ├── DestinationList/
    │   ├── ViewModel/DestinationListViewModel.swift   # @Published 목록
    │   └── View/DestinationListViewController.swift    # 테이블 + 선택 시 push
    └── TripCalendar/
        ├── ViewModel/TripCalendarViewModel.swift       # 기간 선택 + 요약 파생
        └── View/
            ├── TripCalendarViewController.swift         # sink 구독 + UIControl publisher 입력
            └── CalendarDayCell.swift                    # 범위 상태별 스타일
```

## 빌드

Xcode 16+ / iOS 16.0+ / Swift 5.0. 외부 의존성 없음.

```
open ProjectC.xcodeproj
```

## Project A-Z

단계마다 새로운 기술 스택을 하나씩 더해가며, 조금씩 다른 기능을 구현해 나가는 iOS 학습 프로젝트입니다.

| | 추가 스택 |
|---|---|
| A | UIKit + MVVM |
| B | Diffable Data Source |
| **C** | **Combine** |
| D | async/await |
| E | Clean Architecture |
| F | XCTest |
| G | SwiftUI |
| H | Supabase |
| I | FCM |
| J | CoreData |
| K | Tuist |
| L | SPM 모듈화 |
| M | SwiftData |
| N | Objective-C + libexif |
| O | Swift Testing |
| P | UI Test |
| Q | CI/CD (GitHub Actions) |

각 단계는 별도 레포로 관리합니다.
