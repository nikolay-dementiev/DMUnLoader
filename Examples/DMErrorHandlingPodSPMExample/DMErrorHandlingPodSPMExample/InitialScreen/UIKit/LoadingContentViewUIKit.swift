//
//  LoadingContentViewUIKit.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 03.02.2025.
//

import UIKit
import Combine
import DMErrorHandling

final class LoadingContentViewUIKit: UIView {
    private let viewModel = LoadingContentViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func configure(loadingManager: DMLoadingManager?) {
        viewModel.configure(loadingManager: loadingManager)
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
        
        // Buttons
        addButton(title: "Show downloads", action: #selector(viewModel.showDownloads))
        addButton(title: "Simulate an error", action: #selector(viewModel.simulateAnError))
        addButton(title: "Simulate success", action: #selector(viewModel.simulateSuccess))
        addButton(title: "Hide downloads", action: #selector(viewModel.hideLoading))
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    private func addButton(title: String, action: Selector) {
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.baseForegroundColor = .systemBlue
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        button.configuration = configuration
        
        button.addTarget(viewModel, action: action, for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }
    
    private func bindViewModel() {
        viewModel.$isReady
            .receive(on: RunLoop.main)
            .sink { [weak self] isReady in
                self?.isUserInteractionEnabled = isReady
            }
            .store(in: &cancellables)
    }
}
