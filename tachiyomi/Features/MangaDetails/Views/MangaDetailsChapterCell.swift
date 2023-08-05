//
//  MangaDetailsChapterCell.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import UIKit
import RxRelay
import RxSwift

protocol MangaDetailsChapterCellDelegate: AnyObject {
    func mangaDetailsChapterCellDidTapDownload()
}

// MARK: - MangaDetailsChapterCell
class MangaDetailsChapterCell: UITableViewCell, BaseCell {
    static var reuseID: String { return NSStringFromClass(MangaDetailsChapterCell.self) }
    
    // MARK: - Views
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let downloadButton = IconButton(icon: UIImage(systemName: Icons.arrowDownCircle))
    
    weak var delegate: MangaDetailsChapterCellDelegate?
    private let disposeBag = DisposeBag()
    
    var chapter: SourceChapter? {
        didSet {
            titleLabel.text = chapter?.name
            dateLabel.text = chapter?.uploadedDate
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
        
        downloadButton.size = Constants.IconButtonSize.small
        downloadButton.tapHandler = { [weak self] in
            self?.delegate?.mangaDetailsChapterCellDidTapDownload()
        }
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
        }
    }
}
