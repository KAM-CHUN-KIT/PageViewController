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
        static let SEGMENT_HEIGHT: CGFloat = 45
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
    public var isDynamicTabWidth: Bool = true
}
