//
//  MangaDetailsChapterCell.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import UIKit
import RxRelay
import RxSwift
import AHDownloadButton

protocol MangaDetailsChapterCellDelegate: AnyObject {
    func mangaDetailsChapterCellDidTapDownload(_ cell: MangaDetailsChapterCell, at indexPath: IndexPath)
}

// MARK: - MangaDetailsChapterCell
class MangaDetailsChapterCell: UITableViewCell, BaseCell {
    static var reuseID: String { return NSStringFromClass(MangaDetailsChapterCell.self) }
    
    // MARK: - Views
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let downloadButton = AHDownloadButton()
    
    weak var delegate: MangaDetailsChapterCellDelegate?
    private let disposeBag = DisposeBag()
    
    var chapter: SourceChapter? {
        didSet {
            titleLabel.text = chapter?.name
            dateLabel.text = chapter?.uploadedDate
        }
    }
    
    var isDownloaded: Bool = false {
        didSet {
            downloadButton.state = isDownloaded ? .downloaded : .startDownload
        }
    }
    var indexPath: IndexPath?
    
    var downloadState: AHDownloadButton.State = .startDownload {
        didSet {
            downloadButton.state = downloadState
        }
    }
    
    var totalPages: Int = 0
    
    var numberOfDownloadedItems: Int = 0 {
        didSet {
            if totalPages == 0 { return }
            let progress = Double(numberOfDownloadedItems) / Double(totalPages)
            downloadButton.progress = progress
            if progress == 1 {
                downloadState = .downloaded
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - View Config
extension MangaDetailsChapterCell {
    private func configureViews() {
        titleLabel.font = .body
        titleLabel.textAlignment = .left
        stackView.addArrangedSubview(titleLabel)
        dateLabel.font = .desc
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .left
        stackView.addArrangedSubview(dateLabel)
        stackView.axis = .vertical
        stackView.spacing = Constants.Spacing.trivial
        stackView.alignment = .leading
        contentView.addSubview(stackView)
        downloadButton.pendingCircleLineWidth = 3
        downloadButton.downloadingButtonCircleLineWidth = 3
        downloadButton.startDownloadButtonTitle = "Download"
        downloadButton.downloadedButtonTitle = "Saved"
        downloadButton.downloadButtonStateChangedAction = { (button, state) in
            self.didChangeButtonState(for: button, to: state)
        }
        downloadButton.downloadedButtonNonhighlightedTitleColor = .tertiaryLabel
        downloadButton.downloadedButtonNonhighlightedBackgroundColor = .lightGray.withAlphaComponent(0.1)
        downloadButton.delegate = self
        contentView.addSubview(downloadButton)
    }
    private func configureConstraints() {
        stackView.snp.remakeConstraints { make in
            make.top.bottom.leading.equalTo(contentView.layoutMarginsGuide)
            make.trailing.equalTo(downloadButton.snp.leading)
        }
        downloadButton.snp.remakeConstraints { make in
            make.trailing.equalTo(contentView.layoutMarginsGuide)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(120)
        }
    }
}

extension MangaDetailsChapterCell: AHDownloadButtonDelegate {
    private func didChangeButtonState(for button: AHDownloadButton, to state: AHDownloadButton.State) {
        button.isUserInteractionEnabled = (state != .downloaded)
//        switch state {
//        case .startDownload:
//            <#code#>
//        case .pending:
//            <#code#>
//        case .downloading:
//            <#code#>
//        case .downloaded:
//            <#code#>
//        }
    }
    func downloadButton(_ downloadButton: AHDownloadButton, tappedWithState state: AHDownloadButton.State) {
        switch state {
        case .startDownload:
            downloadButton.progress = 0
            downloadButton.state = .pending
            if let indexPath = indexPath {
                self.delegate?.mangaDetailsChapterCellDidTapDownload(self, at: indexPath)
            }
        case .pending:
            break
        case .downloading:
            // button tapped while in downloading state - stop downloading
            downloadButton.progress = 0
            downloadButton.state = .startDownload
        case .downloaded:
            // file is downloaded and can be opened/
            // Change to delete
            downloadButton.progress = 1
        }
    }
}
