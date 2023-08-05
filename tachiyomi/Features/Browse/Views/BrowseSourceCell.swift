//
//  BrowseSourceCell.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import UIKit

class BrowseSourceCell: UITableViewCell, BaseCell {
    static var reuseID: String { NSStringFromClass(BrowseSourceCell.self) }
    
    private let stackView = UIStackView()
    private let logoView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    var logo: UIImage? {
        didSet {
            logoView.image = logo
        }
    }
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        logoView.contentMode = .scaleAspectFit
        contentView.addSubview(logoView)
        
        titleLabel.font = .body
        titleLabel.textColor = .label
        titleLabel.textAlignment = .left
        stackView.addArrangedSubview(titleLabel)
        
        subtitleLabel.font = .small
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .left
        stackView.addArrangedSubview(subtitleLabel)
        
        stackView.axis = .vertical
        stackView.spacing = Constants.Spacing.trivial
        stackView.alignment = .leading
        contentView.addSubview(stackView)
        
        logoView.snp.remakeConstraints { make in
            make.size.equalTo(Constants.IconButtonSize.medium)
            make.centerY.equalToSuperview()
            make.leading.equalTo(contentView.layoutMarginsGuide)
        }
        stackView.snp.remakeConstraints { make in
            make.top.bottom.trailing.equalTo(contentView.layoutMarginsGuide)
            make.leading.equalTo(logoView.snp.trailing).offset(Constants.Spacing.medium)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
