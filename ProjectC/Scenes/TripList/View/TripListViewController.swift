import Combine
import UIKit

private nonisolated enum TripListSection: Hashable { case main }

final class TripListViewController: UIViewController {

  private let viewModel: TripListViewModel
  private let store: TripStore
  private let calendar = Calendar.current
  private var dataSource: UITableViewDiffableDataSource<TripListSection, Trip>!
  private var cancellables = Set<AnyCancellable>()

  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  private let emptyLabel: UILabel = {
    let label = UILabel()
    label.text = "아직 일정이 없어요.\n+ 버튼으로 새 여행을 추가하세요."
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = .secondaryLabel
    label.font = .systemFont(ofSize: 15)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  init(viewModel: TripListViewModel, store: TripStore) {
    self.viewModel = viewModel
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    navigationItem.title = "내 일정"
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(didTapAdd)
    )
    setupViews()
    setupDataSource()
    bindViewModel()
  }

  private func setupViews() {
    view.addSubview(tableView)
    view.addSubview(emptyLabel)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TripCell")

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
      emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
    ])
  }

  private func setupDataSource() {
    dataSource = UITableViewDiffableDataSource<TripListSection, Trip>(
      tableView: tableView
    ) { [calendar] tableView, indexPath, trip in
      let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
      var content = cell.defaultContentConfiguration()
      content.text = trip.summary(using: calendar)
      content.secondaryText = trip.destination.country
      cell.contentConfiguration = content
      cell.selectionStyle = .none
      return cell
    }
  }

  private func bindViewModel() {
    viewModel.$trips
      .sink { [weak self] trips in
        guard let self else { return }
        var snapshot = NSDiffableDataSourceSnapshot<TripListSection, Trip>()
        snapshot.appendSections([.main])
        snapshot.appendItems(trips)
        dataSource.apply(snapshot, animatingDifferences: true)
        emptyLabel.isHidden = !trips.isEmpty
      }
      .store(in: &cancellables)
  }

  @objc private func didTapAdd() {
    let destinationViewController = DestinationListViewController(viewModel: DestinationListViewModel())
    destinationViewController.onSelect = { [weak self] destination in
      guard let self else { return }
      let calendarViewController = TripCalendarViewController(
        viewModel: TripCalendarViewModel(destination: destination, store: store)
      )
      navigationController?.pushViewController(calendarViewController, animated: true)
    }
    navigationController?.pushViewController(destinationViewController, animated: true)
  }
}
