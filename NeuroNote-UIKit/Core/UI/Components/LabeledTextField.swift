//
//  LabeledTextField.swift
//  NeuroNote
//
//  Created by Eclipse on 29/06/25.
//

import UIKit

class LabeledTextField: UIView {
    
    private let horizontalPadding: CGFloat = 30
    private var isPasswordField: Bool = false
    private var trailingButton: UIButton?
    // MARK: - Subviews
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textColor = .systemPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.MontserratRegular, size: 18)
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = .black
        textField.font = UIFont(name: Fonts.MontserratRegular, size: 16) ?? .systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter your text",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                         NSAttributedString.Key.font: UIFont(name: Fonts.MontserratRegular, size: 16) ?? .systemFont(ofSize: 16)]
        )
        textField.autocapitalizationType = .none
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clipsToBounds = true
        return textField
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private func configureTrailingButton(with image: UIImage) {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.frame           = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.tintColor       = .lightGray
        button.addTarget(self, action: #selector(trailingButtonTapped), for: .touchUpInside)
        textField.rightView     = button
        textField.rightViewMode = .always
        trailingButton          = button
    }
    // MARK: - Public helpers
    public func reset() {
        textField.text = nil

        guard isPasswordField else { return }

        if !textField.isSecureTextEntry {
            textField.isSecureTextEntry = true
        }
        
        trailingButton?.isSelected = false
    }
    // MARK: - Initializer
    init(title: String, placeholder: String, trailingImage: UIImage?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        textField.placeholder = placeholder
        buildHierarchy()
        setupConstraints()
        if let img = trailingImage {
            configureTrailingButton(with: img)
        }
        if title == "Password" || title == "Confirm Password"{
            isPasswordField = true
            textField.isSecureTextEntry = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Getter/Setter
    
    public func getText() -> String?{
        return textField.text
    }
    
    // MARK: - ViewSetup
    private func buildHierarchy() {
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(underlineView)
    }
    
    private var trailingAction: (() -> Void)?
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // TitleLabel
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                 constant: -horizontalPadding),
            
            // Text field
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                           constant: 6),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: horizontalPadding),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -horizontalPadding),
            textField.widthAnchor.constraint(equalTo: widthAnchor, constant: -2 * horizontalPadding),
            
            // Underline
            underlineView.topAnchor.constraint(equalTo: textField.bottomAnchor,
                                               constant: 4),
            underlineView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                   constant: horizontalPadding),
            underlineView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                    constant: -horizontalPadding),
            underlineView.heightAnchor.constraint(equalToConstant: 1),
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    @objc private func trailingButtonTapped() {
        guard isPasswordField else { return }
        let iconName = textField.isSecureTextEntry ? "eye.slash" : "eye"
        textField.isSecureTextEntry.toggle()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.trailingButton?.setImage(UIImage(systemName: iconName),
                                          for: .normal)
            self.textField.rightView = self.trailingButton
        }
    }
}

#Preview{
    LabeledTextField(title: "Demo Title", placeholder: "Demo Placeholder", trailingImage: UIImage(systemName: "lock.fill"))
}
