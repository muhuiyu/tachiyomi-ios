//
//  ScrollToTopButton.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/7/23.
//

import UIKit

class ScrollToTopButton: UIView {
    
    private let iconView = UIImageView(image: UIImage(systemName: Icons.arrowUp))
    var tapHandler: (() -> Void)?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        iconView.contentMode = .scaleAspectFit
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        addSubview(iconView)
        iconView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapInView))
        addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    private func didTapInView() {
        tapHandler?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
