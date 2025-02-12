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
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // Header
        titleLabel.attributedText = NSAttributedString(string: AppDelegateHelper.appDescriprtion)
        titleLabel.numberOfLines = 4
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        stackView.addArrangedSubview(titleLabel)
        
        // Buttons
        addButton(title: "Show downloads", action: #selector(viewModel.showDownloads))
        addButton(title: "Simulate an error", action: #selector(viewModel.simulateAnError))
        addButton(title: "Simulate success", action: #selector(viewModel.simulateSuccess))
        addButton(title: "Hide downloads", action: #selector(viewModel.hideLoading))
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    private func addButton(title: String, action: Selector) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
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
