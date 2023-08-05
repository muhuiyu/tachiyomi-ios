//
//  MangaPreviewCell.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import Kingfisher

class MangaPreviewCell: UICollectionViewCell, BaseCell {
    static var reuseID: String = NSStringFromClass(MangaPreviewCell.self)
    
    // MARK: - Views
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    var manga: SourceManga? {
        didSet {
            guard let manga = manga else { return }
            titleLabel.text = manga.title
            titleLabel.numberOfLines = 0
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.imageView.kf.setImage(with: URL(string: manga.thumbnailURL ?? ""),
                                           placeholder: UIImage(systemName: Icons.squareFill))
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        let gradient = CAGradientLayer()
        gradient.frame = imageView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.4).cgColor]
        gradient.locations = [0, 1] // adjust as needed
        imageView.layer.sublayers?.removeAll()
        imageView.layer.insertSublayer(gradient, at: 0)
    }
}

extension MangaPreviewCell {
    private func configureViews(){
        imageView.tintColor = .systemGray.withAlphaComponent(0.3)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        titleLabel.font = .smallBold
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
    }
    private func configureConstraints() {
        imageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalTo(contentView.layoutMarginsGuide)
        }
    }
}
