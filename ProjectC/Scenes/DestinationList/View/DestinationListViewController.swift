import Combine
import UIKit

private nonisolated enum DestinationSection: Hashable { case main }

final class DestinationListViewController: UIViewController {

  private let viewModel: DestinationListViewModel
  private var dataSource: UITableViewDiffableDataSource<DestinationSection, Destination>!
  private var cancellables = Set<AnyCancellable>()

  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.delegate = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  init(viewModel: DestinationListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    navigationItem.title = "여행지 선택"
    setupTableView()
    setupDataSource()
    bindViewModel()
  }

  private func setupTableView() {
    view.addSubview(tableView)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DestinationCell")

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  private func setupDataSource() {
    dataSource = UITableViewDiffableDataSource<DestinationSection, Destination>(
      tableView: tableView
    ) { tableView, indexPath, destination in
      let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationCell", for: indexPath)
      var content = cell.defaultContentConfiguration()
      content.text = destination.name
      content.secondaryText = destination.country
      cell.contentConfiguration = content
      cell.accessoryType = .disclosureIndicator
      return cell
    }
  }

  private func bindViewModel() {
    viewModel.$destinations
      .sink { [weak self] destinations in
        guard let self else { return }
        var snapshot = NSDiffableDataSourceSnapshot<DestinationSection, Destination>()
        snapshot.appendSections([.main])
        snapshot.appendItems(destinations)
        dataSource.apply(snapshot, animatingDifferences: false)
      }
      .store(in: &cancellables)
  }
}

// MARK: - UITableViewDelegate

extension DestinationListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let destination = dataSource.itemIdentifier(for: indexPath) else { return }
    let calendarViewModel = TripCalendarViewModel(destination: destination)
    let calendarViewController = TripCalendarViewController(viewModel: calendarViewModel)
    navigationController?.pushViewController(calendarViewController, animated: true)
  }
}
