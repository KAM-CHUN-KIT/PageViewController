//
//  SegmentedControlOptions.swift
//  NavigationItem
//
//  Created by Kam on 11/5/2017.
//  Copyright © 2017 MyMM. All rights reserved.
//

import UIKit

open class SegmentedControlOptions {
    var enableSegmentControl: Bool
    var segmentedTitles: [String]
    var selectedTitleColors: [UIColor]
    var deSelectedTitleColor: UIColor
    var indicatorColors: [UIColor]
    var hasRedDot: [Bool]?
    var segmentButtonFontSize: CGFloat
    var navigateToTabIndex: Int
    var isDynamicTabWidth: Bool
    
    init(enableSegmentControl: Bool = true, segmentedTitles: [String]? = ["Red", "Black"], selectedTitleColors: [UIColor]? = [UIColor.red, UIColor.darkGray], deSelectedTitleColor: UIColor? = UIColor.lightGray, indicatorColors: [UIColor]? = [UIColor.red, UIColor.black], hasRedDot: [Bool]? = nil, segmentButtonFontSize: CGFloat? = 14, navigateToTabIndex: Int? = 0, isDynamicTabWidth: Bool = true) {
        self.enableSegmentControl = enableSegmentControl
        self.segmentedTitles = segmentedTitles!
        self.selectedTitleColors = selectedTitleColors!
        self.deSelectedTitleColor = deSelectedTitleColor!
        self.indicatorColors = indicatorColors!
        self.hasRedDot = hasRedDot // nil means no red dot
        self.segmentButtonFontSize = segmentButtonFontSize ?? 14
        self.navigateToTabIndex = navigateToTabIndex ?? 0
        self.isDynamicTabWidth = isDynamicTabWidth
    }
}
