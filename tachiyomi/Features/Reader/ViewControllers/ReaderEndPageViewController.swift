//
//  ReaderEndPageViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/6/23.
//

import UIKit
import RxSwift
import RxRelay

protocol ReaderEndPageViewControllerDelegate: AnyObject {
    func readerEndPageViewControllerDidTapNextChapter()
    func readerEndPageViewControllerDidTapRestart()
    func readerEndPageViewControllerDidTapClose()
}

class ReaderEndPageViewController: ViewController {
    
    weak var delegate: ReaderEndPageViewControllerDelegate?
    
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let nextButton = TextButton()
    private let restartButton = TextButton(buttonType: .secondary)
    private let closeButton = TextButton(buttonType: .secondary)
    
    private let canLoadNextChapter: Bool
    init(canLoadNextChapter: Bool) {
        self.canLoadNextChapter = canLoadNextChapter
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
    
}

// MARK: - View Config
extension ReaderEndPageViewController {
    private func configureViews() {
        imageView.image = UIImage(named: "next-chapter")
        imageView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(imageView)
        titleLabel.font = .h3
        titleLabel.text = "Well..."
        titleLabel.textColor = .label
        stackView.addArrangedSubview(titleLabel)
        subtitleLabel.font = .small
        subtitleLabel.text = "This is the end of the chapter"
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .secondaryLabel
        stackView.addArrangedSubview(subtitleLabel)
        
        nextButton.text = canLoadNextChapter ? "Next chapter" : "No more chapters"
        nextButton.isEnable = canLoadNextChapter
        nextButton.tapHandler = { [weak self] in
            self?.delegate?.readerEndPageViewControllerDidTapNextChapter()
        }
        stackView.addArrangedSubview(nextButton)
        restartButton.text = "Read again"
        restartButton.tapHandler = { [weak self] in
            self?.delegate?.readerEndPageViewControllerDidTapRestart()
        }
        stackView.addArrangedSubview(restartButton)
        closeButton.text = "Stop reading"
        closeButton.buttonColor = .systemRed
        closeButton.tapHandler = { [weak self] in
            self?.delegate?.readerEndPageViewControllerDidTapClose()
        }
        stackView.addArrangedSubview(closeButton)
        
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = Constants.Spacing.medium
        view.addSubview(stackView)
    }
    private func configureConstraints() {
        imageView.snp.remakeConstraints { make in
            make.height.equalTo(300)
        }
        nextButton.snp.remakeConstraints { make in
            make.width.equalTo(200)
        }
        restartButton.snp.remakeConstraints { make in
            make.width.equalTo(nextButton)
        }
        closeButton.snp.remakeConstraints { make in
            make.width.equalTo(nextButton)
        }
        stackView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
    }
}

