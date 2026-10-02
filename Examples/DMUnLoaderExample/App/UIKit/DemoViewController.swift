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

        let content = makeButton(
            "Content under the HUD.\nA tap counts when it arrives here.",
            identifier: DemoIdentifier.content,
            configuration: .tinted()
        ) { $0.contentTapped() }
        content.titleLabel?.textAlignment = .center
        content.setContentHuggingPriority(.defaultLow, for: .vertical)

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
        configuration: UIButton.Configuration = .bordered(),
        action: @escaping (DemoModel<LM>) -> Void
    ) -> UIButton {
        var configuration = configuration
        configuration.title = title
        configuration.buttonSize = .large
        let button = UIButton(configuration: configuration, primaryAction: UIAction { [model] _ in
            action(model)
        })
        button.accessibilityIdentifier = identifier
        return button
    }
}
