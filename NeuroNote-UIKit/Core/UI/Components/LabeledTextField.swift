//
//  LabeledTextField.swift
//  NeuroNote
//
//  Created by Eclipse on 29/06/25.
//

import UIKit

protocol LabeledTextFieldDelegate: AnyObject {
    func labeledTextField(_ textField: LabeledTextField, didChangeText text: String)
}

class LabeledTextField: UIView {
    
    private var isPasswordField: Bool = false
    private var trailingButton: UIButton?
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    private let textField = UITextField()
    private let underline = UIView()
    
    private let horizontalPadding: CGFloat = 20
    private let verticalSpacing: CGFloat = 8
    
    weak var delegate: LabeledTextFieldDelegate?
    
    init(placeholder: String, trailingImage: UIImage?) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        setupTextFieldContainer()
        setupTextField(with: placeholder)
        
        if let trailing = trailingImage {
            configureTrailingButton(with: trailing)
        }
        if placeholder.lowercased().contains("email") {
            textField.keyboardType = .emailAddress
        }
        if placeholder.lowercased().contains("password") {
            isPasswordField = true
            textField.isSecureTextEntry = true
        }
        
        buildHierarchy()
        setupConstraints()
        setupFocusBehavior()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    public func getText() -> String? {
        return textField.text
    }
    
    public func reset() {
        textField.text = nil
        if isPasswordField {
            textField.isSecureTextEntry = true
            trailingButton?.isSelected = false
        }
    }
    
    // MARK: - Setup
    
    private func setupTextFieldContainer() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 14
        blurView.clipsToBounds = true
    }
    
    private func setupTextField(with placeholder: String) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: Fonts.MontserratRegular, size: 15)
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont(
                    name: Fonts.MontserratRegular,
                    size: 15
                ) ?? .systemFont(ofSize: 15)
            ]
        )
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func configureTrailingButton(with image: UIImage) {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(trailingButtonTapped),
            for: .touchUpInside
        )
        textField.rightView = button
        textField.rightViewMode = .always
        trailingButton = button
    }
    
    private func buildHierarchy() {
        addSubview(blurView)
        blurView.contentView.addSubview(textField)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // TextField Container
            blurView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: verticalSpacing
            ),
            blurView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: horizontalPadding
            ),
            blurView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -horizontalPadding
            ),
            blurView.heightAnchor.constraint(equalToConstant: 48),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            // TextField
            textField.leadingAnchor.constraint(
                equalTo: blurView.leadingAnchor,
                constant: 12
            ),
            textField.trailingAnchor.constraint(
                equalTo: blurView.trailingAnchor,
                constant: -12
            ),
            textField.topAnchor.constraint(equalTo: blurView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: blurView.bottomAnchor)
        ])
    }
    
    // MARK: - Focus Styling
    private func setupFocusBehavior() {
        textField.addTarget(
            self,
            action: #selector(focused),
            for: .editingDidBegin
        )
        textField.addTarget(
            self,
            action: #selector(unfocused),
            for: .editingDidEnd
        )
    }
    
    @objc private func focused() {
        UIView.animate(withDuration: 0.2) {
            self.blurView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @objc private func unfocused() {
        UIView.animate(withDuration: 0.2) {
            self.blurView.layer.borderColor = .none
        }
    }
    
    // MARK: - Password Eye Toggle
    @objc private func trailingButtonTapped() {
        guard isPasswordField else { return }
        textField.isSecureTextEntry.toggle()
        let iconName = textField.isSecureTextEntry ? "eye" : "eye.slash"
        trailingButton?.setImage(
            UIImage(systemName: iconName),
            for: .normal
        )
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        delegate?.labeledTextField(self, didChangeText: sender.text ?? "")
    }
}

#Preview {
    LabeledTextField(
                     placeholder: "Enter your password",
                     trailingImage: UIImage(systemName: "eye")
    )
}
