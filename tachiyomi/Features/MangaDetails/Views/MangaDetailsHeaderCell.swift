//
//  MangaDetailsHeaderCell.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import RxRelay
import RxSwift

protocol MangaDetailsHeaderCellDelegate: AnyObject {
    func mangaDetailsHeaderCellDidTapAddToLibrary()
    func mangaDetailsHeaderCellDidTapGoToWebsite()
}

// MARK: - MangaDetailsHeaderCell
class MangaDetailsHeaderCell: UITableViewCell, BaseCell {
    static var reuseID: String { return NSStringFromClass(MangaDetailsHeaderCell.self) }
    
    private let topStackView = UIStackView()
    private let thumbnailView = UIImageView()
    private let infoStackView = UIStackView()       // top + button
    private let infoTopStackView = UIStackView()    // title, author
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let statusView = MangaDetailsHeaderStatusView()
    private let buttonStackView = UIStackView()
    private let addToLibraryButton = TextButton(buttonType: .primary)
    private let websiteButton = TextButton(buttonType: .primary)
    
    private let descriptionLabel = UILabel()
    
    weak var delegate: MangaDetailsHeaderCellDelegate?
    
    private let disposeBag = DisposeBag()
    let manga: BehaviorRelay<SourceManga?> = BehaviorRelay(value: nil)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
        
        manga
            .asObservable()
            .subscribe { [weak self] _ in
                self?.configureData()
            }
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Config
extension MangaDetailsHeaderCell {
    private func configureViews() {
        thumbnailView.contentMode = .scaleAspectFit
        thumbnailView.clipsToBounds = true
        topStackView.addArrangedSubview(thumbnailView)
        
        titleLabel.font = .h3
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        infoTopStackView.addArrangedSubview(titleLabel)
        authorLabel.font = .smallBold
        authorLabel.numberOfLines = 0
        authorLabel.textAlignment = .left
        infoTopStackView.addArrangedSubview(authorLabel)
        statusView.status = .ongoing
        infoTopStackView.addArrangedSubview(statusView)
        infoTopStackView.axis = .vertical
        infoTopStackView.alignment = .leading
        infoTopStackView.spacing = Constants.Spacing.small
        infoStackView.addArrangedSubview(infoTopStackView)
        
        addToLibraryButton.text = "Add to library"
        addToLibraryButton.textFont = .small
        addToLibraryButton.buttonColor = .systemGroupedBackground
        addToLibraryButton.textColor = .label
        addToLibraryButton.buttonHeight = Constants.TextButton.Height.small
        addToLibraryButton.tapHandler = { [weak self] in
            self?.delegate?.mangaDetailsHeaderCellDidTapAddToLibrary()
        }
        buttonStackView.addArrangedSubview(addToLibraryButton)
        websiteButton.text = "Go to website"
        websiteButton.textFont = .small
        websiteButton.buttonColor = .systemGroupedBackground
        websiteButton.textColor = .label
        websiteButton.buttonHeight = Constants.TextButton.Height.small
        websiteButton.tapHandler = { [weak self] in
            self?.delegate?.mangaDetailsHeaderCellDidTapGoToWebsite()
        }
        buttonStackView.addArrangedSubview(websiteButton)
        buttonStackView.axis = .vertical
        buttonStackView.alignment = .leading
        buttonStackView.spacing = Constants.Spacing.small
        infoStackView.addArrangedSubview(buttonStackView)
        
        infoStackView.axis = .vertical
        infoStackView.alignment = .leading
        infoStackView.spacing = Constants.Spacing.medium
        topStackView.addArrangedSubview(infoStackView)
        
        topStackView.spacing = Constants.Spacing.large
        topStackView.axis = .horizontal
        topStackView.alignment = .center
        contentView.addSubview(topStackView)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.font = .small
        contentView.addSubview(descriptionLabel)
    }
    private func configureConstraints() {
        thumbnailView.snp.remakeConstraints { make in
            make.height.equalTo(thumbnailView.snp.width).multipliedBy(1.5)
            // TODO: - Calculate this
            make.width.equalTo(170)
        }
        
        topStackView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalTo(contentView.layoutMarginsGuide)
        }
        addToLibraryButton.snp.remakeConstraints { make in
            make.width.equalTo(150)
        }
        websiteButton.snp.remakeConstraints { make in
            make.width.equalTo(addToLibraryButton)
        }
        descriptionLabel.snp.remakeConstraints { make in
            make.top.equalTo(topStackView.snp.bottom).offset(Constants.Spacing.medium)
            make.leading.trailing.bottom.equalTo(contentView.layoutMarginsGuide)
        }
    }
    private func configureData() {
        guard let manga = manga.value else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.thumbnailView.kf.setImage(with: URL(string: manga.thumbnailURL ?? ""))
            self.titleLabel.text = manga.title
            self.authorLabel.text = manga.author ?? "unknown"
            self.statusView.status = manga.status
            self.descriptionLabel.text = manga.description
            
            if self.canAddToLibrary() {
                self.addToLibraryButton.isEnable = true
                self.addToLibraryButton.text = "Add to library"
            } else {
                self.addToLibraryButton.isEnable = false
                self.addToLibraryButton.text = "Saved in library"
            }
            
        }
    }
    private func canAddToLibrary() -> Bool {
        guard let mangaURL = manga.value?.url else { return false }
        return !LocalStorage.shared.libraryContains(mangaURL)
    }
}

// MARK: - MangaDetailsHeaderStatusView
class MangaDetailsHeaderStatusView: UIView {
    
    private let iconView = UIImageView()
    private let textLabel = UILabel()
    
    var status: SourceManga.Status? = .ongoing {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.iconView.image = self.status?.icon
                self.textLabel.text = self.status?.name
            }
        }
    }
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        iconView.image = status?.icon
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)
        textLabel.text = status?.name
        textLabel.font = .small
        textLabel.textAlignment = .left
        textLabel.textColor = .secondaryLabel
        addSubview(textLabel)
    }
    private func configureConstraints() {
        iconView.snp.remakeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(Constants.IconButtonSize.slight)
        }
        textLabel.snp.remakeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(Constants.Spacing.trivial)
            make.top.bottom.trailing.equalToSuperview()
        }
    }
}
