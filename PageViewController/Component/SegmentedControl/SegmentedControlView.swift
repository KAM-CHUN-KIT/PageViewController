//
//  SegmentedView.swift
//  PageViewController
//
//  Created by Kam on 13/1/2021.
//  Copyright © 2021 Kam. All rights reserved.
//

import UIKit

class SegmentedControlView: UIScrollView {
    private struct FrameConstant {
        static let Y_BUFFER = 14
        static let SELECTOR_WIDTH_BUFFER: CGFloat = 0.0
        static let BUTTON_WIDTH_BUFFER: CGFloat = 24.0
        static let BOUNCE_BUFFER = 10
        static let ANIMATION_SPEED: CGFloat = 0.2
        static let SELECTOR_Y_BUFFER: CGFloat = 36
        static let SELECTOR_HEIGHT: CGFloat = 2.0
        static let SEGMENT_HEIGHT: CGFloat = 45
        static let SEGMENT_Y: CGFloat = 0.0
    }
    
    private var buttons = [UIButton]()
    private var selectionIndicator: UIView
    
    ///real time calculation
    private var X_BUFFER = 0
    private var SELECTOR_WIDTH: CGFloat {
        get { // Do real time calculation of the indicator width.
            var btnWidth: CGFloat = 0.0
            var width: CGFloat = 0.0
            if segmentedTitles.count > 0, buttons.count > currentPageIndex, segmentedTitles.count > currentPageIndex, segmentedTitles.count > nextPageIndex {
                let title = segmentedTitles[currentPageIndex]
                let nextTitle = segmentedTitles[nextPageIndex]
                btnWidth = buttons[currentPageIndex].frame.size.width
                let currentWidth = title.getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: segmentedFontSize))
                width = currentWidth
                let nextWidth = nextTitle.getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: segmentedFontSize))
                    
                let ratio: CGFloat
                if pageWidth > pageScrollViewOffset.x { //scroll to left
                    ratio = (pageWidth - pageScrollViewOffset.x) / pageWidth
                } else { //scroll to right
                    ratio = (pageScrollViewOffset.x - pageWidth) / pageWidth
                }
                let diffWidth = (nextWidth - currentWidth) * ratio
                width += diffWidth
            }
            width += FrameConstant.SELECTOR_WIDTH_BUFFER
            X_BUFFER = Int((btnWidth - width)/2)
            return width
        }
    }
    
    private var isSegmentScrollable = false
    private var isPageScrollingFlag = false
    
    ///Customizable configuration, from SegmentedControlOptions
    private var selectedTitleColor: UIColor
    private var deSelectedTitleColor: UIColor
    private var indicatorColor: UIColor
    private var dynamicWidthTab: Bool // custom control to your segment button with fixed width or display the entire title
    private var navigateToTabIndex = 0 /* bring to specific tab by assigning index */
    private var segmentedTitles: [String]
    private var segmentedFontSize: CGFloat = 14
    
    
    ///from `Paging` protocol
    private var pageWidth: CGFloat = 0.0
    private var currentPageIndex = 0
    private var nextPageIndex = 0
    
    ///from `Scrolling` protocol
    private var pageScrollViewOffset: CGPoint = .zero
    internal var pagerDelegate: PagerDelegate?
    
    override init(frame: CGRect) {
        let option = SegmentedControlOptions.default
        selectedTitleColor = option.selectedTitleColor
        deSelectedTitleColor = option.deSelectedTitleColor
        indicatorColor = option.indicatorColor
        dynamicWidthTab = option.isDynamicTabWidth
        navigateToTabIndex = option.navigateToTabIndex
        segmentedTitles = option.segmentedTitles
        segmentedFontSize = option.segmentButtonFontSize
        selectionIndicator = UIView()
        super.init(frame: frame)
        
        initializeSegmentButtons()
        initializeIndicator()
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeSegmentButtons() {
        var contentSizeWidth: CGFloat = 0.0
        for title in segmentedTitles {
            contentSizeWidth += title.getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: segmentedFontSize)) + FrameConstant.BUTTON_WIDTH_BUFFER
        }
        
        var remainAverageW:CGFloat = 0.0
        if contentSizeWidth > self.bounds.width {
            self.isSegmentScrollable = true
            self.contentSize = CGSize(width: contentSizeWidth, height: FrameConstant.SEGMENT_HEIGHT)
        } else if dynamicWidthTab {
            let remainWidth = self.bounds.width - contentSizeWidth
            remainAverageW = remainWidth / CGFloat(segmentedTitles.count)
        }
        
        if segmentedTitles.count >= numOfPageCount {//safety guard
            for i in 0..<numOfPageCount {
                var buttonWidth: CGFloat = 0
                
                if isSegmentScrollable || dynamicWidthTab {
                    buttonWidth = segmentedTitles[i].getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: segmentedFontSize)) + FrameConstant.BUTTON_WIDTH_BUFFER
                } else {
                    buttonWidth = (pageWidth / CGFloat(numOfPageCount))
                }
                
                if dynamicWidthTab && !isSegmentScrollable {
                    buttonWidth += remainAverageW
                }
                
                let previousButtonMaxX = (buttons.count > 0) ? buttons[max(i - 1, 0)].frame.maxX : 0
                let button = UIButton(frame: CGRect(x: previousButtonMaxX,
                                                           y: 0,
                                                           width: buttonWidth,
                                                           height: FrameConstant.SEGMENT_HEIGHT))
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: segmentedFontSize)
                button.tag = i
                let title = segmentedTitles[i]
                button.setTitle(title, for: .normal)
                
                button.addTarget(self, action: #selector(self.segmentButtonClicked), for: .touchUpInside)
                if i == 1 {
                    button.titleLabel?.adjustsFontSizeToFitWidth = true
                }
                button.setTitleColor(deSelectedTitleColor, for: .normal)
                button.setTitleColor(selectedTitleColor, for: .highlighted)
                button.setTitleColor(selectedTitleColor, for: .selected)
                
                buttons.append(button)
                self.addSubview(button)
            }
        }
        buttons[navigateToTabIndex].isSelected = true
    }
    
    private func initializeIndicator() {
        let x: CGFloat// = CGFloat(X_BUFFER)
        var width = SELECTOR_WIDTH
        
        let title = segmentedTitles[navigateToTabIndex]
        width = title.getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: segmentedFontSize)) + FrameConstant.SELECTOR_WIDTH_BUFFER
        x = buttons[navigateToTabIndex].center.x - width / 2
        
        self.currentPageIndex = navigateToTabIndex
        
        self.selectionIndicator = UIView(frame: CGRect(x: x, y: FrameConstant.SELECTOR_Y_BUFFER, width: width, height: FrameConstant.SELECTOR_HEIGHT))
        selectionIndicator.layer.cornerRadius = FrameConstant.SELECTOR_HEIGHT/2
        selectionIndicator.backgroundColor = indicatorColor
        self.addSubview(selectionIndicator)
    }
}

extension SegmentedControlView {
    @objc func segmentButtonClicked(_ sender: UIButton!) {
        if !self.isPageScrollingFlag {
            
            let completion = { [weak self] in
                if let aSelf = self {
                    aSelf.currentPageIndex = aSelf.nextPageIndex
                    for btn in aSelf.buttons {
                        btn.isSelected = false
                    }
                    sender.isSelected = true
                }
            }
            
            self.nextPageIndex = sender.tag
            updateIndicator()
            self.pagerDelegate?.move(to: sender.tag, completion: completion)
        }
    }
    
    private func updateIndicator() {
        let title = segmentedTitles[nextPageIndex]
        let width = title.getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: segmentedFontSize)) + FrameConstant.SELECTOR_WIDTH_BUFFER
        let xPos = self.buttons[nextPageIndex].center.x - width / 2
        
        UIView.animate(withDuration: 0.2, animations: {
            self.selectionIndicator.frame = CGRect(
                x: xPos,
                y: CGFloat(self.selectionIndicator.frame.origin.y),
                width: width,
                height: CGFloat(self.selectionIndicator.frame.size.height)
            )
        })
    }
}

extension SegmentedControlView: Paging {
    var numOfPageCount: Int {
        buttons.count
    }
    
    var currentPage: Int {
        return self.currentPageIndex
    }
    
    var nextPage: Int {
        return self.nextPageIndex
    }
    
    func update(pageWidth width: CGFloat) {
        self.pageWidth = width
    }
    
    func update(currentPage page: Int) {
        self.currentPageIndex = page
    }
    
    func update(nextPage page: Int) {
        self.nextPageIndex = page
    }
}

extension SegmentedControlView: Scrolling {
    func scroll(offset: CGPoint, percent: CGFloat) {
        
    }
    
    func updateIsPageScrolling(_ isScrolling: Bool) {
        self.isPageScrollingFlag = isScrolling
    }
}
