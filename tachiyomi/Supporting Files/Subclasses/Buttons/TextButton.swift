//
//  TextButton.swift
//  Translation Practice
//
//  Created by Mu Yu on 2/11/20.
//

import UIKit

class TextButton: UIView {
    
    private let textLabel = UILabel()
    private let containerView = UIView()
    
    var buttonType: ButtonType {
        didSet {
            configureButtons()
        }
    }
    
    enum ButtonType {
        case primary
        case secondary
        case text
    }
    
    var text: String? {
        get { return textLabel.text }
        set { textLabel.text = newValue }
    }
    var textColor: UIColor? {
        didSet {
            textLabel.textColor = textColor
        }
    }
    var textFont: UIFont? {
        didSet {
            textLabel.font = textFont
        }
    }
    var buttonHeight: CGFloat = 44 {
        didSet {
            containerView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(buttonHeight)
            }
        }
    }
    var buttonColor: UIColor? {
        didSet {
            switch buttonType {
                case .primary:
                    containerView.backgroundColor = buttonColor
                case .secondary:
                    textLabel.textColor = buttonColor
                    containerView.layer.borderColor = buttonColor?.cgColor
                case .text:
                    textLabel.textColor = buttonColor
            }
        }
    }
    var isEnable: Bool = true {
        didSet {
            if isEnable {
                layer.opacity = 1
            }
            else {
                layer.opacity = 0.4
            }
        }
    }
    var alignment: NSTextAlignment = .center {
        didSet {
            textLabel.textAlignment = alignment
        }
    }
    
    var tapHandler: (() -> Void)?
    
    init(frame: CGRect = .zero, buttonType: ButtonType = .primary) {
        self.buttonType = buttonType
        super.init(frame: frame)
        configureViews()
        configureButtons()
        configureGestures()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Actions
extension TextButton {
    @objc
    private func didTapButton() {
        if isEnable { tapHandler?() }
    }
}
// MARK: - View Config
extension TextButton {
    private func configureViews() {
        textLabel.font = UIFont.buttonText
        containerView.addSubview(textLabel)
        containerView.layer.cornerRadius = Constants.TextButton.cornerRadius
        addSubview(containerView)
    }
    private func configureButtons() {
        switch buttonType {
        case .primary:
            textLabel.textColor = .white
            containerView.backgroundColor = .systemBlue
        case .secondary:
            textLabel.textColor = .systemBlue
            containerView.backgroundColor = .clear
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
        case .text:
            textLabel.textColor = .systemBlue
            containerView.backgroundColor = .clear
        }
    }
    private func configureGestures() {
        let tapRecoginier = UITapGestureRecognizer(target: self, action: #selector(didTapButton))
        addGestureRecognizer(tapRecoginier)
    }
    private func configureConstraints() {
        textLabel.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        containerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(buttonHeight)
        }
    }
}
