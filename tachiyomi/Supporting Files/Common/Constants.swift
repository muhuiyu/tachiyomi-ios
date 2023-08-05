//
//  Constants.swift
//  Lango
//
//  Created by Mu Yu on 8/1/21.
//

import UIKit

struct Constants {
    static let cornerRadius: CGFloat = 8
    static let paddingToTop: CGFloat = 16
    static let textSpacingSmall: CGFloat = 4
    static let horizonalPadding: CGFloat = 8
    static let horizonalPaddingLarge: CGFloat = 8
    struct TextButton {
        static let cornerRadius: CGFloat = 16
        static let cornerRadiusLarge: CGFloat = 24
        struct Height {
            static let medium: CGFloat = 44
            static let large: CGFloat = 60
            static let small: CGFloat = 32
        }
    }
    struct HeaderHeight {
        static let withLargeTitle: CGFloat = 100
    }
    struct Card {
        static let cornerRadius: CGFloat = 8
        struct Size {
            static let small: CGFloat = 120
            static let medium: CGFloat = 200
            static let large: CGFloat = 300
        }
    }
    struct Grid {
        static let cornerRadius: CGFloat = 8
        static let inset: CGFloat = Constants.Spacing.medium
        struct Size {
            static let small: CGFloat = 60
            static let medium: CGFloat = 120
            static let large: CGFloat = 180
            static let enormous: CGFloat = 240
        }
    }
    struct AvatarImageSize {
        static let enormous: CGFloat = 96
        static let large: CGFloat = 44
        static let medium: CGFloat = 32
        static let small: CGFloat = 24
    }
    struct IconButtonSize {
        static let superb: CGFloat = 80
        static let enormous: CGFloat = 60
        static let large: CGFloat = 44
        static let medium: CGFloat = 32
        static let small: CGFloat = 24
        static let trivial: CGFloat = 20
        static let slight: CGFloat = 12
    }
    struct ChipView {
        static let cornerRadius: CGFloat = 16
        static let iconPadding: CGFloat = 4
    }
    struct Spacing {
        /// 36
        static let enormous: CGFloat = 36
        /// 24
        static let large: CGFloat = 24
        /// 16
        static let medium: CGFloat = 16
        /// 8
        static let small: CGFloat = 8
        /// 4
        static let trivial: CGFloat = 4
        /// 2
        static let slight: CGFloat = 2
    }
    struct ProgressBar {
        static let height: CGFloat = 8
        static let cornerRadius: CGFloat = 4
    }
    struct ImageSize {
        static let cover: CGFloat = 250
        static let illustation: CGFloat = 200
        static let header: CGFloat = 150
        static let thumbnail: CGFloat = 44
        static let cellBackground: CGFloat = 64
        static let fitScreen: CGFloat = 375
        static let sessionQuizFlagHeight: CGFloat = 200
    }
    struct TextField {
        static let cornerRaduis: CGFloat = 8
        static let height: CGFloat = 44
    }
}
