import UIKit

final class CalendarDayCell: UICollectionViewCell {

  enum RangeState {
    case none
    case start
    case middle
    case end
    case single
  }

  private let rangeBar: UIView = {
    let view = UIView()
    view.backgroundColor = .systemBlue.withAlphaComponent(0.15)
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let dayCircle: UIView = {
    let view = UIView()
    view.backgroundColor = .systemBlue
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let dayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 16, weight: .medium)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    dayCircle.layer.cornerRadius = dayCircle.bounds.height / 2
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    rangeBar.isHidden = true
    dayCircle.isHidden = true
  }

  private func setupViews() {
    contentView.addSubview(rangeBar)
    contentView.addSubview(dayCircle)
    contentView.addSubview(dayLabel)

    NSLayoutConstraint.activate([
      rangeBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      rangeBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      rangeBar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      rangeBar.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -8),

      dayCircle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      dayCircle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      dayCircle.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -8),
      dayCircle.widthAnchor.constraint(equalTo: dayCircle.heightAnchor),

      dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }

  func configure(day: CalendarDay, rangeState: RangeState) {
    dayLabel.text = "\(day.dayNumber)"

    guard day.isInCurrentMonth else {
      dayLabel.textColor = .tertiaryLabel
      rangeBar.isHidden = true
      dayCircle.isHidden = true
      return
    }

    switch rangeState {
    case .none:
      rangeBar.isHidden = true
      dayCircle.isHidden = true
      dayLabel.textColor = day.isToday ? .systemBlue : .label
    case .middle:
      rangeBar.isHidden = false
      dayCircle.isHidden = true
      dayLabel.textColor = .systemBlue
    case .start, .end, .single:
      rangeBar.isHidden = true
      dayCircle.isHidden = false
      dayLabel.textColor = .white
    }
  }
}
