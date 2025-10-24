//
//  DMUnLoaderPodExample
//
//  Created by Mykola Dementiev
//

import UIKit
import Combine
import DMUnLoader

final class LoadingContentViewUIKit<
    Provider: DMLoadingViewProvider,
    LM: DMLoadingManager
>: UIView {
    private let viewModel = LoadingContentViewModel<Provider,LM>()
    private var cancellables = Set<AnyCancellable>()
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func configure(loadingManager: LM?, provider: Provider?) {
        viewModel.configure(
            loadingManager: loadingManager,
            provider: provider
        )
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Container settings
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // Header
        titleLabel.attributedText = NSAttributedString(
            string: AppDelegateHelper.appDescriprtion,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .title3),
                .foregroundColor: UIColor.label
            ]
        )
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(titleLabel)
        
        // Add padding around the title label
        let titleContainer = UIView()
        titleContainer.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -16)
        ])
        stackView.addArrangedSubview(titleContainer)
        
        let buttonsContainer = UIStackView()
        buttonsContainer.axis = .vertical
        buttonsContainer.spacing = 10
        buttonsContainer.alignment = .fill
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(buttonsContainer)
        
        // Buttons
        addButton(
            title: "Simulate Loading",
            action: #selector(viewModel.showDownloads),
            into: buttonsContainer
        )
        addButton(
            title: "Simulate Error",
            action: #selector(viewModel.simulateAnError),
            into: buttonsContainer
        )
        addButton(
            title: "Simulate Success",
            action: #selector(viewModel.simulateSuccess),
            into: buttonsContainer
        )
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    private func addButton(title: String, action: Selector, into stackView: UIStackView) {
        let button = CapsuleButton(type: .system)
        
        button.addTarget(viewModel, action: action, for: .touchUpInside)
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.baseForegroundColor = .tintColor
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 40,
            bottom: 8,
            trailing: 40
        )
        button.configuration = configuration
        
        // Tint color
        button.tintColor = .systemBlue
        
        // Border styling via layer
        button.layer.borderWidth = 2
        button.layer.borderColor = button.tintColor.cgColor
        button.layer.masksToBounds = true
        
        // Make the button expand horizontally in a stack view, if desired
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addConstraint(
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        )
        
        stackView.addArrangedSubview(button)
        
        button.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
    
    //MARK: HELPERs
    
    final class CapsuleButton: UIButton {
        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = bounds.height / 2
        }
    }
}
