//
//  SegmentedControlOptions.swift
//  NavigationItem
//
//  Created by Kam on 11/5/2017.
//  Copyright © 2017 Kam. All rights reserved.
//

import UIKit

open class SegmentedControlOptions {
    static let `default` = SegmentedControlOptions()
    
    var segmentedTitles: [String] = ["Red", "Black"]
    var selectedTitleColor: UIColor = UIColor.black
    var deSelectedTitleColor: UIColor = UIColor.lightGray
    var indicatorColor: UIColor = UIColor.red
    var hasRedDot: [Bool]?
    var segmentButtonFontSize: CGFloat = 14
    var navigateToTabIndex: Int = 0
    var isDynamicTabWidth: Bool = true
//
//    init(segmentedTitles: [String]? = ["Red", "Black"],
//         selectedTitleColor: UIColor? = UIColor.black,
//         deSelectedTitleColor: UIColor? = UIColor.lightGray,
//         indicatorColor: UIColor? = UIColor.red,
//         hasRedDot: [Bool]? = nil,
//         segmentButtonFontSize: CGFloat? = 14,
//         navigateToTabIndex: Int? = 0,
//         isDynamicTabWidth: Bool = true) {
//        self.segmentedTitles = segmentedTitles!
//        self.selectedTitleColor = selectedTitleColor!
//        self.deSelectedTitleColor = deSelectedTitleColor!
//        self.indicatorColor = indicatorColor!
//        self.hasRedDot = hasRedDot // nil means no red dot
//        self.segmentButtonFontSize = segmentButtonFontSize ?? 14
//        self.navigateToTabIndex = navigateToTabIndex ?? 0
//        self.isDynamicTabWidth = isDynamicTabWidth
//    }
}
