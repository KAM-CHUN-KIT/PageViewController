//
//  SegmentedControlView.swift
//  NavigationItem
//
//  Created by Kam on 10/5/2017.
//  Copyright © 2017 MyMM. All rights reserved.
//

import UIKit

@objc protocol SegmentedControlDelegate{
    @objc optional func segmentButtonClicked(_ sender: UIButton)
}

class SegmentedControlView: UIView {
    
    weak var delegate: SegmentedControlDelegate?
    
    private var segmentedTitles: [String]
    private var selectedTitleColors: [UIColor]
    private var deSelectedTitleColor: UIColor
    private var indicatorColors: [UIColor]
    private var hasRedDot: [Bool]?
    private var segmentButtonFontSize: CGFloat
    private var numOfPageCount: Int

    var currentPageIndex = 0
    var nextPageIndex = 0
    var isPageScrollingFlag = false
    
    private var X_BUFFER = 0
    private var Y_BUFFER = 14
    private var SELECTOR_WIDTH_BUFFER: CGFloat = -15.0
    private var SEGMENT_HEIGHT: CGFloat = 45
    private var BOUNCE_BUFFER = 10
    private var ANIMATION_SPEED: CGFloat = 0.2
    private var SELECTOR_Y_BUFFER: CGFloat = 36
    private var SELECTOR_HEIGHT: CGFloat = 2
    private var SELECTOR_WIDTH: CGFloat {
        get {
            let btnWidth = self.frame.size.width / CGFloat(numOfPageCount)
            var width = btnWidth
            if segmentedTitles.count > currentPageIndex {
                let title = segmentedTitles[currentPageIndex]/*, let nextTitle = segmentedTitles?[nextPageIndex]*/
                let currentWidth = title.getTextWidth(height: SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: segmentButtonFontSize))
                width = currentWidth
            }
            width += SELECTOR_WIDTH_BUFFER
            X_BUFFER = Int((btnWidth - width)/2)
            return width
        }
    }
    private var selectionIndicator: UIView!
    var segmentButtons: [SegmentedButton] {
        get {
            var buttons = [SegmentedButton]()
            for case let button as SegmentedButton in self.subviews {
                buttons.append(button)
            }
            
            return buttons
        }
    }
    
    init(frame: CGRect, options: SegmentedControlOptions? = SegmentedControlOptions()) {
        self.segmentedTitles = options?.segmentedTitles ?? []
        self.selectedTitleColors = options?.selectedTitleColors ?? []
        self.deSelectedTitleColor = options?.deSelectedTitleColor ?? UIColor.lightGray
        self.indicatorColors = options?.indicatorColors ?? []
        self.hasRedDot = options?.hasRedDot
        self.segmentButtonFontSize = options?.segmentButtonFontSize ?? 14
        self.numOfPageCount = self.segmentedTitles.count
        
        super.init(frame: frame)
        self.setup()
        self.addSelectionIndicator()
    }
    
    private func setup() {
        
        for i in 0 ..< numOfPageCount {
            let button = SegmentedButton(frame: CGRect(x: CGFloat(i) * (self.frame.size.width / CGFloat(numOfPageCount)),
                y: 0,
                width: self.frame.size.width / CGFloat(numOfPageCount),
                height: self.frame.size.height))
            
            button.tag = i
            let title = segmentedTitles[i]
            button.setTitle(title, for: UIControl.State())
            
            if let shouldShowRedDot = hasRedDot?[i], shouldShowRedDot == true {
                let textWidth = title.getTextWidth(height: self.frame.size.height, font: UIFont.systemFont(ofSize: segmentButtonFontSize))
                let view = UIView(frame: CGRect(x: (button.frame.size.width + textWidth) / 2, y: 12, width: 5, height: 5))
                view.backgroundColor = .red
                button.addSubview(view)
            }
            button.addTarget(self, action: #selector(self.segmentButtonClicked), for: .touchUpInside)
            button.fontSize = segmentButtonFontSize
            button.setTitleColor(deSelectedTitleColor, for: UIControl.State())
            button.setTitleColor(deSelectedTitleColor, for: .highlighted)
            button.setTitleColor(selectedTitleColors[i], for: .selected)
            
            if i == 0 {
                button.isUserInteractionEnabled = false
                button.isSelected = true
            }

            self.addSubview(button)
        }
        
    }
    
    private func addSelectionIndicator() {
        let width = SELECTOR_WIDTH
        selectionIndicator = UIView(frame: CGRect(
            x: CGFloat(X_BUFFER),
            y: SELECTOR_Y_BUFFER,
            width: width,
            height: SELECTOR_HEIGHT))
        selectionIndicator.layer.cornerRadius = SELECTOR_HEIGHT/2
        
        selectionIndicator.backgroundColor = indicatorColors[currentPageIndex]
        self.addSubview(selectionIndicator)
    }
    
    func updateIndicator() {
        //debug , update indicator color
        let title = segmentedTitles[nextPageIndex]
        let width = title.getTextWidth(height: SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: segmentButtonFontSize)) + SELECTOR_WIDTH_BUFFER
        let xPos = self.segmentButtons[nextPageIndex].center.x - width / 2
            
        UIView.animate(withDuration: 0.2, animations: {
            self.selectionIndicator.frame = CGRect(
                x: xPos,
                y: CGFloat(self.selectionIndicator.frame.origin.y),
                width: width,
                height: CGFloat(self.selectionIndicator.frame.size.height)
            )
            
            if self.indicatorColors.count > self.nextPageIndex {
                self.selectionIndicator.backgroundColor = self.indicatorColors[self.nextPageIndex]
            }
        })
    }
    
    @objc func segmentButtonClicked(_ sender: UIButton!) {
        if !self.isPageScrollingFlag && !sender.isSelected {
            self.isPageScrollingFlag = true
            self.updateSegmentButtons(sender.tag)
            delegate?.segmentButtonClicked?(sender)
        }
    }
    
    func pageViewTransitionCompleted(_ index: Int) {
        self.updateSegmentButtons(index)
        self.selectionIndicator.backgroundColor = indicatorColors[index]
    }
    
    private func updateSegmentButtons(_ index: Int) {
        var i = 0
        for case let button in segmentButtons {
            button.isSelected = (i == index)
            i += 1
            
            button.isUserInteractionEnabled = !button.isSelected
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView, currentPageIndex: Int) {
        let ratio = self.frame.size.width/scrollView.frame.size.width
        
        var contentOffsetX = scrollView.contentOffset.x
        if scrollView.contentOffset.x <= 0 || scrollView.contentOffset.x >= scrollView.frame.size.width * 2 {
            contentOffsetX = scrollView.frame.size.width
        }
        
        let xFromCenter: Int = Int((scrollView.frame.size.width - contentOffsetX) * ratio)
        let width = SELECTOR_WIDTH
        let xCoor: CGFloat  = CGFloat(X_BUFFER) + ((self.frame.size.width / CGFloat(numOfPageCount)) * CGFloat(currentPageIndex))
        self.selectionIndicator.frame = CGRect(
            x: xCoor - CGFloat(xFromCenter/numOfPageCount),
            y: CGFloat(selectionIndicator.frame.origin.y),
            width: width,
            height: CGFloat(selectionIndicator.frame.size.height)
        )
        
        var destinationColor: UIColor
        let fraction = abs(CGFloat(xFromCenter/numOfPageCount) / (self.frame.size.width / CGFloat(numOfPageCount)))
        
        if CGFloat(xFromCenter/numOfPageCount) > 0 {
            let index = currentPageIndex == 0 ? 0 : currentPageIndex - 1
            destinationColor = indicatorColors[index]
        }
        else {
            let index = currentPageIndex == indicatorColors.count - 1 ? indicatorColors.count - 1 : currentPageIndex + 1
            destinationColor = indicatorColors[index]
        }
        selectionIndicator.backgroundColor = UIColor.colorBetween(indicatorColors[currentPageIndex], destinationColor: destinationColor, fraction: fraction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
