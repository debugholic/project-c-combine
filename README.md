# Project C — Combine

[Project A-Z](#project-a-z) 의 C 단계.

단계마다 새로운 기술 스택을 하나씩 더해가며, 조금씩 다른 기능을 구현해 나갑니다.
C 단계에서는 B(UIKit + MVVM + Diffable)의 **클로저 바인딩을 Combine으로 전환**하고,
앱을 **여행 플래너**로 확장합니다 — 여행지를 고르고 달력에서 기간을 정해 여행 일정을 만듭니다.

## 다루는 기술

- UIKit (Programmatic, Storyboard 없음)
- MVVM
- Diffable Data Source (테이블/컬렉션 양쪽)
- **Combine** (입력·출력 양방향 바인딩, 공유 저장소) ← 이번 단계 추가분

## 기능

**내 일정 목록**에서 시작해 새 여행을 추가하는 3단계 플로우로 일정을 만듭니다.

1. **내 일정 목록** — 저장된 여행을 보여줍니다. `+` 로 새 여행을 추가합니다.
2. **여행지 선택** — 여행지 목록(이름 + 나라)에서 하나를 고릅니다.
3. **여행 기간 지정** — 달력에서 시작일·종료일을 탭해 기간을 정하면 하단에 요약(`Tokyo · 5박 6일 (May 10 – May 15)`)이 표시됩니다. **완료**하면 새 일정이 생성되어 목록에 저장됩니다.

- 기간: 시작일 → 종료일 탭으로 범위를 연한색 밴드로 표시. 시작일 이전 탭 시 앞당김, 완성 후 새 탭은 새로 시작, 같은 날 두 번이면 당일치기
- 완료 버튼은 기간이 모두 정해졌을 때만 활성화됩니다

## B 단계와 달라진 점

| | B (Diffable) | C (+ Combine) |
|---|---|---|
| 바인딩 | `onUpdate` 클로저 | `@Published` / `AnyPublisher` + `sink`·`store(in:)` |
| 입력 | delegate / target-action → VM 메서드 | UIControl 이벤트 → Combine publisher → VM |
| 화면 | 단일 달력 화면 | 내 일정 → 여행지 → 달력 3단계 + 일정 저장 |
| 공유 상태 | 없음 | `TripStore`(`@Published`)를 화면 간 주입·구독 |
| 선택 상태 | 단일 날짜 + 메모 | 날짜 범위(start~end) + 여행지 |

핵심 아이디어: 각 ViewModel은 상태를 `@Published`로 노출하고, 요약·헤더·완료 가능 여부는 `CombineLatest`/`map`으로 파생합니다.
완료 시 생성한 `Trip`은 공유 `TripStore`에 쌓이고, 목록 화면은 `store.$trips`를 구독해 자동 갱신됩니다.
목록은 `UITableViewDiffableDataSource`, 달력은 `UICollectionViewDiffableDataSource`로 그립니다.

## 구조

```
ProjectC/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift              # 루트 = 내 일정 목록, TripStore 생성·주입
├── Extensions/
│   └── UIControl+Publisher.swift        # UIControl 이벤트 → Combine publisher
├── Model/
│   ├── Destination.swift                # 여행지 (이름 + 나라)
│   ├── CalendarDay.swift                # Hashable — diffable 식별자
│   ├── Trip.swift                       # 여행지 + 기간 + 요약(summary)
│   └── TripStore.swift                  # @Published trips 공유 저장소
└── Scenes/
    ├── TripList/                        # 내 일정 목록 (루트)
    │   ├── ViewModel/TripListViewModel.swift       # store 구독 → @Published trips
    │   └── View/TripListViewController.swift        # 목록 + [+] → 여행지 선택
    ├── DestinationList/
    │   ├── ViewModel/DestinationListViewModel.swift
    │   └── View/DestinationListViewController.swift # 선택은 onSelect 클로저로 위임
    └── TripCalendar/
        ├── ViewModel/TripCalendarViewModel.swift   # 기간 선택 + 요약 + 완료(저장)
        └── View/
            ├── TripCalendarViewController.swift     # sink 구독 + 완료 버튼
            └── CalendarDayCell.swift                # 범위 연한색 밴드
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
