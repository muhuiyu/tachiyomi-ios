//
//  RoundButton.swift
//  Tonari
//
//  Created by Mu Yu on 11/1/21.
//

import UIKit

class RoundButton: UIView {
    private let iconImageView = UIImageView()
    private let containerView = UIView()
    private let circleView = CircleView()
    
    var icon: UIImage? {
        get { return iconImageView.image }
        set { iconImageView.image = newValue }
    }
    
    var buttonColor: UIColor? {
        get { return containerView.backgroundColor }
        set { containerView.backgroundColor = newValue }
    }
    
    var iconColor: UIColor? {
        get { return iconImageView.tintColor }
        set { iconImageView.tintColor = newValue }
    }
    var tapHandler: (() -> Void)?
    // button size?
    
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
    init(frame: CGRect = .zero, icon: UIImage?, buttonColor: UIColor, iconColor: UIColor) {
        super.init(frame: frame)
        self.icon = icon
        self.buttonColor = buttonColor
        self.iconColor = iconColor
        configureViews()
        configureGestures()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Actions
extension RoundButton {
    @objc
    private func didTapButton() {
        if isEnable { tapHandler?() }
    }
}
// MARK: - View Config
extension RoundButton {
    private func configureViews() {
        
        iconImageView.image = icon
        iconImageView.sizeToFit()
        containerView.addSubview(iconImageView)
        
        containerView.backgroundColor = buttonColor
        circleView.addSubview(containerView)
        
        addSubview(circleView)
    }
    private func configureGestures() {
        let tapRecoginier = UITapGestureRecognizer(target: self, action: #selector(didTapButton))
        addGestureRecognizer(tapRecoginier)
    }
    private func configureConstraints() {
        iconImageView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        containerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        circleView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(circleView.snp.height)
        }
    }
}
