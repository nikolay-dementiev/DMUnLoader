//
//  LoadingContentViewUIKit.swift
//  DMErrorHandlingPodExample
//
//  Created by Nikolay Dementiev on 03.02.2025.
//

import UIKit
import DMErrorHandling

final class LoadingContentViewUIKit: UIView {
    var loadingManager: DMLoadingManager!
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
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
        addButton(title: "Show downloads", action: #selector(startLoadingAction))
        addButton(title: "Simulate an error", action: #selector(simulateError))
        addButton(title: "Simulate success", action: #selector(simulateSuccess))
        addButton(title: "Hide downloads", action: #selector(hideLoading))
        
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
        button.addTarget(self, action: action, for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }
    
    @objc private func startLoadingAction() {
        loadingManager.showLoading()
        simulateTask()
    }
    
    @objc private func simulateError() {
        let error = DMAppError.custom("Some test Error occured!")
        loadingManager.showFailure(error) { [weak self] in
            self?.startLoadingAction()
        }
    }
    
    @objc private func simulateSuccess() {
        loadingManager.showSuccess("Data successfully loaded!")
    }
    
    @objc private func hideLoading() {
        loadingManager.hide()
    }
    
    private func simulateTask() {
        Task {
            try? await Task.sleep(for: .seconds(6))
            await MainActor.run {
                loadingManager.showSuccess("Successfully completed!")
            }
        }
    }
}
