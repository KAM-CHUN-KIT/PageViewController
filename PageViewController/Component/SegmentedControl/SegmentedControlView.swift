//
//  SegmentedView.swift
//  PageViewController
//
//  Created by Kam on 13/1/2021.
//  Copyright © 2021 Kam. All rights reserved.
//

import UIKit

class SegmentedControlView: UIScrollView {
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
                let currentWidth = title.getTextWidth(height: SegmentedControlOptions.FrameConstant.SEGMENT_HEIGHT, font: segmentedFont)
                width = currentWidth
                let nextWidth = nextTitle.getTextWidth(height: SegmentedControlOptions.FrameConstant.SEGMENT_HEIGHT, font: segmentedFont)
                    
                let ratio: CGFloat
                if pageWidth > pageScrollViewOffset.x { //scroll to left
                    ratio = max((pageWidth - pageScrollViewOffset.x) / pageWidth, 0.0)
                } else { //scroll to right
                    ratio = max((pageScrollViewOffset.x - pageWidth) / pageWidth, 0.0)
                }
                let diffWidth = (nextWidth - currentWidth) * (ratio.isNaN ? 0 : ratio)
                width += diffWidth
            }
            width += SegmentedControlOptions.FrameConstant.SELECTOR_WIDTH_BUFFER
            X_BUFFER = Int((btnWidth - width)/2)
            return width
        }
    }
    
    private var isSegmentScrollable = false
    private var isPageScrollingFlag = false
    
    ///Customizable configuration, from SegmentedControlOptions
    private let segmentedViewBackgroundColor: UIColor
    private let selectedTitleColor: UIColor
    private let deSelectedTitleColor: UIColor
    private let indicatorColor: UIColor
    private let indicatorMarginBelowButton: CGFloat
    private var navigateToTabIndex = 0 /* bring to specific tab by assigning index */
    private let segmentedTitles: [String]
    private let segmentedFont: UIFont
    
    
    ///from `Paging` protocol
    private var pageWidth: CGFloat {
        get {
            return self.frame.width
        }
    }
    private var currentPageIndex = 0
    private var nextPageIndex = 0
    
    ///from `Scrolling` protocol
    private var pageScrollViewOffset: CGPoint = .zero
    internal var pagerDelegate: PagerDelegate?
    
    override init(frame: CGRect) {
        let option = SegmentedControlOptions.default
        segmentedViewBackgroundColor = option.segmentedViewBackgroundColor
        selectedTitleColor = option.selectedTitleColor
        deSelectedTitleColor = option.deSelectedTitleColor
        indicatorColor = option.indicatorColor
        indicatorMarginBelowButton = option.indicatorMarginBelowButton
        navigateToTabIndex = option.navigateToTabIndex
        segmentedTitles = option.segmentedTitles
        segmentedFont = option.segmentButtonFont
        selectionIndicator = UIView()
        super.init(frame: frame)
        self.backgroundColor = segmentedViewBackgroundColor
        
        initializeSegmentButtons()
        initializeIndicator()
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeSegmentButtons() {
        let centerY = self.center.y
        for i in 0..<segmentedTitles.count {
            let previousButtonMaxX = (buttons.count > 0) ? buttons[max(i - 1, 0)].frame.maxX : 0
            let button = UIButton(frame: CGRect(x: previousButtonMaxX + SegmentedControlOptions.FrameConstant.BUTTON_MARGIN,
                                                y: .zero,
                                                width: .zero,
                                                height: .zero))
            button.titleLabel?.font = segmentedFont
            button.tag = i
            let title = segmentedTitles[i]
            button.setTitle(title, for: .normal)
            
            button.addTarget(self, action: #selector(self.segmentButtonClicked), for: .touchUpInside)
            button.setTitleColor(deSelectedTitleColor, for: .normal)
            button.setTitleColor(selectedTitleColor, for: .highlighted)
            button.setTitleColor(selectedTitleColor, for: .selected)
            button.sizeToFit()
            button.center.y = centerY
            buttons.append(button)
            self.addSubview(button)
        }
        buttons[navigateToTabIndex].isSelected = true
        let contentSizeWidth = (buttons.last?.frame.maxX ?? 0) + SegmentedControlOptions.FrameConstant.BUTTON_MARGIN
        if contentSizeWidth > self.bounds.width {
            self.isSegmentScrollable = true
            self.contentSize = CGSize(width: contentSizeWidth, height: SegmentedControlOptions.FrameConstant.SEGMENT_HEIGHT)
        }
    }
    
    private func initializeIndicator() {
        let x: CGFloat// = CGFloat(X_BUFFER)
        var width = SELECTOR_WIDTH
        let buttonBottom = buttons.first?.frame.maxY ?? 0
        
        let title = segmentedTitles[navigateToTabIndex]
        width = title.getTextWidth(height: SegmentedControlOptions.FrameConstant.SEGMENT_HEIGHT, font: segmentedFont) + SegmentedControlOptions.FrameConstant.SELECTOR_WIDTH_BUFFER
        x = buttons[navigateToTabIndex].center.x - width / 2
        
        self.currentPageIndex = navigateToTabIndex
        
        self.selectionIndicator = UIView(frame: CGRect(x: x, y: buttonBottom + indicatorMarginBelowButton, width: width, height: SegmentedControlOptions.FrameConstant.SELECTOR_HEIGHT))
        selectionIndicator.layer.cornerRadius = SegmentedControlOptions.FrameConstant.SELECTOR_HEIGHT/2
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
        let width = title.getTextWidth(height: SegmentedControlOptions.FrameConstant.SEGMENT_HEIGHT, font: segmentedFont) + SegmentedControlOptions.FrameConstant.SELECTOR_WIDTH_BUFFER
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
    
    var buttonsWidth: CGFloat {
        return buttons.compactMap({ $0.frame.width }).reduce(0, +)
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
        guard isPageScrollingFlag else { return }
        self.pageScrollViewOffset = offset
        if offset.x <= 0 || offset.x >= pageWidth * 2 {
            let previousButton = buttons[currentPageIndex]
            previousButton.isSelected = false
            currentPageIndex = nextPageIndex
            let currentButton = buttons[currentPageIndex]
            currentButton.isSelected = true
        }
        animateIndicator(offset: offset)
        animateTitleColor(percent: percent)
    }
    
    func updateIsPageScrolling(_ isScrolling: Bool) {
        self.isPageScrollingFlag = isScrolling
    }
    
    private func animateIndicator(offset: CGPoint) {
        guard offset.x >= 0 && offset.x <= pageWidth*2 else { return } //avoid scrolling too fast
        let xFromCenter: Int = Int(pageWidth - offset.x)
        let width = SELECTOR_WIDTH
        
        let xCoor: CGFloat = CGFloat(X_BUFFER) + buttons[currentPageIndex].frame.origin.x
        let ratio: CGFloat = ((buttons[currentPageIndex].frame.size.width + SegmentedControlOptions.FrameConstant.BUTTON_MARGIN*2 + buttons[nextPageIndex].frame.size.width) / 2) / pageWidth
        
        self.selectionIndicator.frame = CGRect(
            x: xCoor - CGFloat(xFromCenter) * ratio,
            y: CGFloat(selectionIndicator.frame.origin.y),
            width: width,
            height: CGFloat(selectionIndicator.frame.size.height)
        )
        
        if isSegmentScrollable {
            pagingSegmentedControl()
        }
    }
    
    private func animateTitleColor(percent: CGFloat) {
        guard currentPageIndex != nextPageIndex else { return }
        buttons[currentPageIndex].titleLabel?.textColor = selectedTitleColor.multiplyColor(by: (1-percent)).addColor(with: deSelectedTitleColor.multiplyColor(by: percent))
        buttons[nextPageIndex].titleLabel?.textColor = selectedTitleColor.multiplyColor(by: percent).addColor(with: deSelectedTitleColor.multiplyColor(by: (1-percent)))
    }
    
    private func pagingSegmentedControl() {
        if buttons.count > currentPageIndex {
            let targetButton = buttons[currentPageIndex]
            let outsideBound: Bool = (self.contentOffset.x + self.frame.size.width) <= targetButton.frame.maxX
                || self.contentOffset.x > targetButton.frame.origin.x
            
            if outsideBound {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.1, animations: {
                        let pointX = targetButton.frame.maxX - self.frame.size.width
                        self.contentOffset = CGPoint(x: max(pointX, 0), y: 0)
                    })
                }
            }
        }
    }
}
