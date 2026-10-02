import Combine
import UIKit
import DMUnLoader

/// The UIKit version of the demo screen. It has the same controls and the same
/// accessibility identifiers as `DemoScreen`.
final class DemoViewController<LM: DMLoadingManager>: UIViewController {
    private let model: DemoModel<LM>
    private let contentTapsLabel = UILabel()
    private let retriesLabel = UILabel()
    private var subscriptions = Set<AnyCancellable>()

    init(model: DemoModel<LM>) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configure(contentTapsLabel, identifier: DemoIdentifier.contentTaps)
        configure(retriesLabel, identifier: DemoIdentifier.retries)

        let triggers = UIStackView(arrangedSubviews: [
            makeButton("Loading", identifier: DemoIdentifier.showLoading) { $0.showLoading() },
            makeButton("Success", identifier: DemoIdentifier.showSuccess) { $0.showSuccess() },
            makeButton("Failure", identifier: DemoIdentifier.showFailure) { $0.showFailure() }
        ])
        triggers.spacing = 12
        triggers.distribution = .fillEqually
        // The content control below takes the free height, not the row of triggers.
        triggers.setContentHuggingPriority(.defaultHigh, for: .vertical)

        let content = makeContentControl()

        let stack = UIStackView(arrangedSubviews: [contentTapsLabel, retriesLabel, triggers, content])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let guide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])

        model.$contentTaps
            .sink { [contentTapsLabel] in contentTapsLabel.text = DemoText.contentTaps($0) }
            .store(in: &subscriptions)
        model.$retries
            .sink { [retriesLabel] in retriesLabel.text = DemoText.retries($0) }
            .store(in: &subscriptions)
    }

    private func configure(_ label: UILabel, identifier: String) {
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.accessibilityIdentifier = identifier
    }

    private func makeButton(
        _ title: String,
        identifier: String,
        action: @escaping (DemoModel<LM>) -> Void
    ) -> UIButton {
        var configuration = UIButton.Configuration.bordered()
        configuration.title = title
        configuration.buttonSize = .large
        let button = UIButton(configuration: configuration, primaryAction: UIAction { [model] _ in
            action(model)
        })
        button.accessibilityIdentifier = identifier
        return button
    }

    /// The control under the HUD: a button that fills the rest of the screen, with a text
    /// that fills the button.
    private func makeContentControl() -> UIButton {
        let button = UIButton(primaryAction: UIAction { [model] _ in
            model.contentTapped()
        })
        button.backgroundColor = view.tintColor.withAlphaComponent(0.15)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.accessibilityLabel = DemoText.contentLabel
        button.accessibilityIdentifier = DemoIdentifier.content
        button.setContentHuggingPriority(.defaultLow, for: .vertical)

        let text = UILabel()
        text.text = DemoText.content
        text.font = .preferredFont(forTextStyle: .footnote)
        text.adjustsFontForContentSizeCategory = true
        text.textColor = view.tintColor
        text.numberOfLines = 0
        text.isAccessibilityElement = false
        text.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        text.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(text)
        NSLayoutConstraint.activate([
            text.topAnchor.constraint(equalTo: button.topAnchor, constant: 12),
            text.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 12),
            text.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -12),
            text.bottomAnchor.constraint(lessThanOrEqualTo: button.bottomAnchor, constant: -12)
        ])
        return button
    }
}
