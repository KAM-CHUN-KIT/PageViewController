//
//  SegmentedControlOptions.swift
//  NavigationItem
//
//  Created by Kam on 11/5/2017.
//  Copyright © 2017 Kam. All rights reserved.
//

import UIKit

open class SegmentedControlOptions {
    public static let `default` = SegmentedControlOptions()
    struct FrameConstant {
        static let Y_BUFFER = 14
        static let SELECTOR_WIDTH_BUFFER: CGFloat = 0.0
        static let BUTTON_MARGIN: CGFloat = 20.0
        static let SELECTOR_HEIGHT: CGFloat = 1.0
        static let SEGMENT_HEIGHT: CGFloat = 45 * preferredFontSizeRatioForSubHeading
        static let SEGMENT_Y: CGFloat = 0.0
        static let TOP_MARGIN = 8.0
    }
    
    public var segmentedTitles: [String] = ["Red", "Black"]
    public var segmentedViewBackgroundColor: UIColor = UIColor.white
    public var selectedTitleColor: UIColor = UIColor.black
    public var deSelectedTitleColor: UIColor = UIColor.lightGray
    public var indicatorColor: UIColor = UIColor.red
    public var indicatorMarginBelowButton: CGFloat = 0
    public var hasRedDot: [Bool]?
    public var segmentButtonFont: UIFont = UIFont.systemFont(ofSize: 14)
    public var navigateToTabIndex: Int = 0
    
    private static var preferredFontSizeRatioForSubHeading: CGFloat { // FIX-ME to support all fonts later
        // this link will be useful : https://engineering.deptagency.com/ios-accessibility-part-1-dynamic-type
        let fontCategory = UIApplication.shared.preferredContentSizeCategory
        
        switch fontCategory {
        case UIContentSizeCategory.accessibilityExtraExtraExtraLarge:
            return 49/15
        case UIContentSizeCategory.accessibilityExtraExtraLarge:
            return 42/15
        case UIContentSizeCategory.accessibilityExtraLarge:
            return 36/15
        case UIContentSizeCategory.accessibilityLarge:
            return 30/15
        case UIContentSizeCategory.accessibilityMedium:
            return 25/15
        case UIContentSizeCategory.extraExtraExtraLarge:
            return 21/15
        case UIContentSizeCategory.extraExtraLarge:
            return 19/15
        case UIContentSizeCategory.extraLarge:
            return 17/15
        case UIContentSizeCategory.large:
            return 1.0 // 15/15
        case UIContentSizeCategory.medium:
            return 14/15
        case UIContentSizeCategory.small:
            return 13/15
        case UIContentSizeCategory.extraSmall:
            return 12/15
        case UIContentSizeCategory.unspecified:
            return 1.0
        default:
            return 1.0
        }
    }
}


