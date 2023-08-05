//
//  ReaderNoPageFoundViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import UIKit
import RxSwift
import RxRelay

class ReaderNoPageFoundViewController: ViewController {
    
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
    
}

// MARK: - View Config
extension ReaderNoPageFoundViewController {
    private func configureViews() {
        imageView.image = UIImage(named: "404-image")
        imageView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(imageView)
        titleLabel.font = .h3
        titleLabel.text = "Ooops 404!"
        titleLabel.textColor = .label
        stackView.addArrangedSubview(titleLabel)
        subtitleLabel.font = .small
        subtitleLabel.text = "Sorry about that, but the page you are looking for just disappeared... bad magic?"
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .secondaryLabel
        stackView.addArrangedSubview(subtitleLabel)
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = Constants.Spacing.medium
        view.addSubview(stackView)
    }
    private func configureConstraints() {
        imageView.snp.remakeConstraints { make in
            make.height.equalTo(200)
        }
        stackView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
    }
}

