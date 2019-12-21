//
//  PageViewController.swift
//  Pager
//
//  Created by Kam on 21/2/2017.
//  Copyright © 2017 Kam. All rights reserved.
//

import UIKit

public protocol PageViewControllerDelegate: NSObjectProtocol {
    func getIndex() -> Int
    func setIndex(index: Int)
}

open class PageViewController: UIViewController {
    
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
        static let SEARCHBAR_HEIGHT: CGFloat = 44
        static let SEGMENT_FONT_SIZE: CGFloat = 14
    }
    
    private var dynamicWidthTab: Bool = false // custom control to your segment button with fixed width or display the entire title
    private var shouldHaveSegment = false // enable segment tab row
    private var navigateToTabIndex = 0 /* bring to specific tab by assigning index */
    private var viewControllers: [UIViewController]?
    private var segmentedTitles: [String]?
    private var buttons = [UIButton]()
    private var selectedTitleColors: [UIColor]?
    private var deSelectedTitleColor: UIColor?
    private var indicatorColors: [UIColor]?
    
    private var X_BUFFER = 0
    private var SELECTOR_WIDTH: CGFloat {
        get { // Do real time calculation of the indicator width.
            var btnWidth: CGFloat = 0.0
            var width: CGFloat = 0.0
            if let titles = segmentedTitles, titles.count > 0, buttons.count > currentPageIndex, titles.count > currentPageIndex, titles.count > nextPageIndex {
                let title = titles[currentPageIndex]
                let nextTitle = titles[nextPageIndex]
                btnWidth = buttons[currentPageIndex].frame.size.width
                let currentWidth = title.getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: FrameConstant.SEGMENT_FONT_SIZE))
                width = currentWidth
                let nextWidth = nextTitle.getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: FrameConstant.SEGMENT_FONT_SIZE))
                    
                var diffWidth = nextWidth - currentWidth
                if self.pageViewController.view.frame.size.width > self.pageScrollView.contentOffset.x { //scroll to left
                    let ratio = (self.pageViewController.view.frame.size.width - self.pageScrollView.contentOffset.x) / self.pageViewController.view.frame.size.width
                        
                    diffWidth *= ratio
                } else { //scroll to right
                    let ratio = (self.pageScrollView.contentOffset.x - self.pageViewController.view.frame.size.width) / self.pageViewController.view.frame.size.width
                        
                    diffWidth *= ratio
                }
                width += diffWidth
            }
            width += FrameConstant.SELECTOR_WIDTH_BUFFER
            X_BUFFER = Int((btnWidth - width)/2)
            return width
        }
    }
    
    private var pageViewController: UIPageViewController!
    private var pageScrollView: UIScrollView!
    var isContainSearchBar = false
    private var numOfPageCount = 0
    private var currentPageIndex = 0
    private var nextPageIndex = 0
    
    private var isPageScrollingFlag = false
    private var hasAppearedFlag = false
    
    private var segmentedControlView: UIScrollView? {
        didSet {
            self.segmentedControlView?.showsVerticalScrollIndicator = false
            self.segmentedControlView?.showsHorizontalScrollIndicator = false
        }
    }
    private var isSegmentScrollable = false
    
    private var selectionIndicator: UIView!
    private var backgroundColor: UIColor?
    private let IndicatorOffset: CGFloat = 5
    var searchBar: UISearchBar?
    private var initialIndex: Int? = nil
    
    init(vcs: [UIViewController]?, options: SegmentedControlOptions? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let vcs = vcs {
            self.viewControllers = vcs
            numOfPageCount = vcs.count
            for (index, vc) in vcs.enumerated() {
                if let delegate = vc as? PageViewControllerDelegate {
                    delegate.setIndex(index: index)
                }
            }
        }
        
        if let opt = options {
            self.shouldHaveSegment = true
            self.dynamicWidthTab = opt.isDynamicTabWidth
            self.navigateToTabIndex = opt.navigateToTabIndex
            let titles = opt.segmentedTitles
            self.segmentedTitles = titles
            for (index, title) in titles.enumerated() {
                if buttons.count > index {
                    let button = buttons[index]
                    button.setTitle(title, for: .normal)
                }
            }
            self.selectedTitleColors = opt.selectedTitleColors
            self.deSelectedTitleColor = opt.deSelectedTitleColor
            self.indicatorColors = opt.indicatorColors
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasAppearedFlag, let _ = self.viewControllers, let _ = self.segmentedTitles { //will only setup UI with local data in willAppear
            self.reveal()
        }
        hasAppearedFlag = true
    }
    
    open func reveal() {
        if shouldHaveSegment {
            setupSegmentButtons()
        }
        
        if isContainSearchBar {
            setupSearchBar()
        }
        
        setupPageViewController(initialIndex ?? 0)
        
        // Indicator must setup after PageViewController
        if shouldHaveSegment {
            setupIndicator(initialIndex ?? 0)
        }
        
        if navigateToTabIndex > 0 && self.buttons.count > navigateToTabIndex {
            self.segmentButtonClicked(self.buttons[navigateToTabIndex])
        }
        
        self.hasAppearedFlag = true
    }
    
    private func setupSegmentButtons() {
        self.segmentedControlView = UIScrollView(frame: CGRect(x: 0, y: FrameConstant.SEGMENT_Y, width: self.view.frame.size.width, height: FrameConstant.SEGMENT_HEIGHT))
        
        guard let titles = self.segmentedTitles, let segmentedControl = self.segmentedControlView else {
            return
        }
        
        var contentSizeWidth: CGFloat = 0.0
        for title in titles {
            contentSizeWidth += title.getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: FrameConstant.SEGMENT_FONT_SIZE)) + FrameConstant.BUTTON_WIDTH_BUFFER
        }
        
        var remainAverageW:CGFloat = 0.0
        if contentSizeWidth > segmentedControl.bounds.width {
            self.isSegmentScrollable = true
            segmentedControl.contentSize = CGSize(width: contentSizeWidth, height: FrameConstant.SEGMENT_HEIGHT)
        } else if dynamicWidthTab {
            let remainWidth = segmentedControl.bounds.width - contentSizeWidth
            remainAverageW = remainWidth / CGFloat(titles.count)
        }
        
        if titles.count >= numOfPageCount {//safety guard
            for i in 0..<numOfPageCount {
                var buttonWidth: CGFloat = 0
                
                if isSegmentScrollable || dynamicWidthTab {
                    buttonWidth = titles[i].getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: FrameConstant.SEGMENT_FONT_SIZE)) + FrameConstant.BUTTON_WIDTH_BUFFER
                } else {
                    buttonWidth = ((self.view.frame.size.width) / CGFloat(numOfPageCount))
                }
                
                if dynamicWidthTab && !isSegmentScrollable {
                    buttonWidth += remainAverageW
                }
                
                let previousButtonMaxX = (buttons.count > 0) ? buttons[max(i - 1, 0)].frame.maxX : 0
                let button = SegmentedButton(frame: CGRect(x: previousButtonMaxX,
                                                           y: 0,
                                                           width: buttonWidth,
                                                           height: FrameConstant.SEGMENT_HEIGHT))
                button.fontSize = FrameConstant.SEGMENT_FONT_SIZE
                
                button.tag = i
                let title = titles[i]
                button.setTitle(title, for: .normal)
                
                button.addTarget(self, action: #selector(self.segmentButtonClicked), for: .touchUpInside)
                if i == 1 {
                    button.titleLabel?.adjustsFontSizeToFitWidth = true
                }
                button.setTitleColor(.lightGray, for: .normal)
                button.setTitleColor(.black, for: .highlighted)
                button.setTitleColor(.black, for: .selected)
                
                buttons.append(button)
                segmentedControl.addSubview(button)
            }
        }
        
        self.view.addSubview(self.segmentedControlView!)
        buttons[initialIndex ?? 0].isSelected = true
    }
    
    private func setupSearchBar() {
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: segmentedControlView?.frame.maxY ?? FrameConstant.SEGMENT_Y, width: view.frame.size.width, height: FrameConstant.SEARCHBAR_HEIGHT))
        self.view.addSubview(searchBar!)
    }
    
    private func setupPageViewController(_ initialIndex: Int? = nil) {
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        if let bgColor = self.backgroundColor {
            pageViewController.view.backgroundColor = bgColor
        }
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        for view in pageViewController.view.subviews {
            if let scrollview = view as? UIScrollView {
                self.pageScrollView = scrollview
                scrollview.delegate = self
                break
            }
        }
        
        var startY = self.segmentedControlView?.frame.maxY ?? FrameConstant.SEGMENT_Y + FrameConstant.SEGMENT_HEIGHT
        
        if let searchBar = self.searchBar {
            startY = searchBar.frame.maxY
        }
        
        self.pageViewController.view.frame = CGRect(x: 0, y: startY, width: view.frame.size.width, height: view.frame.maxY - startY)
        
        if let vcs = self.viewControllers, vcs.count > 0 {
            self.pageViewController.setViewControllers([vcs[initialIndex ?? 0]], direction: .forward, animated: true, completion: nil)
            
            if isContainSearchBar {
                resetSearchBar(vcs[initialIndex ?? 0])
            }
            
        }
        self.view.addSubview(pageViewController.view)
    }
    
    private func setupIndicator(_ initialIndex: Int? = nil) {
        var x = CGFloat(X_BUFFER)
        var width = SELECTOR_WIDTH
        
        if let titles = segmentedTitles, let initialIndex = initialIndex {
            let title = titles[initialIndex]
            width = title.getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: FrameConstant.SEGMENT_FONT_SIZE)) + FrameConstant.SELECTOR_WIDTH_BUFFER
            x = buttons[initialIndex].center.x - width / 2
            
            currentPageIndex = initialIndex
        }
        
        selectionIndicator = UIView(frame: CGRect(x: x, y: FrameConstant.SELECTOR_Y_BUFFER, width: width, height: FrameConstant.SELECTOR_HEIGHT))
        selectionIndicator.layer.cornerRadius = FrameConstant.SELECTOR_HEIGHT/2
        selectionIndicator.backgroundColor = UIColor.red
        segmentedControlView?.addSubview(selectionIndicator)
    }
    
    @objc func segmentButtonClicked(_ sender: UIButton!) {
        if !self.isPageScrollingFlag {
            
            let tempIdx = self.currentPageIndex
            
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
            
            if sender.tag > tempIdx {
                if let vcs = self.viewControllers, vcs.count > sender.tag {
                    
                    if isContainSearchBar {
                        resetSearchBar(vcs[sender.tag])
                    }
                    
                    pageViewController.setViewControllers([vcs[sender.tag]], direction: .forward, animated: false, completion: { (complete) in
                        if complete {
                            completion()
                        }
                    })
                }
            } else if sender.tag < tempIdx {
                if let vcs = self.viewControllers, vcs.count > sender.tag {
                    
                    if isContainSearchBar {
                        resetSearchBar(vcs[sender.tag])
                    }
                    
                    pageViewController.setViewControllers([vcs[sender.tag]], direction: .reverse, animated: false, completion: { (complete) in
                        if complete {
                            completion()
                        }
                    })
                }
            }
        }
    }
    
    private func updateIndicator() {
        if let titles = segmentedTitles {
            let title = titles[nextPageIndex]
            let width = title.getTextWidth(height: FrameConstant.SEGMENT_HEIGHT, font: UIFont.systemFont(ofSize: FrameConstant.SEGMENT_FONT_SIZE)) + FrameConstant.SELECTOR_WIDTH_BUFFER
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
    
    private func selectTab(atIndex index: Int) {
        if buttons.count > index {
            segmentButtonClicked(buttons[index])
        }
    }
    
    private func tab(atIndex index: Int, loadTitle title: String) {
        if buttons.count > index {
            let button = buttons[index]
            button.setTitle(title, for: .normal)
        }
    }
    
    private func resetSearchBar(_ viewController: UIViewController) {
        searchBar!.text = ""
        searchBar!.resignFirstResponder()
        searchBar!.delegate?.searchBar!(searchBar!, textDidChange: "")
    }
}

//MARK:- PageViewController Delegate
extension PageViewController : UIPageViewControllerDelegate {
    func indexForViewController(_ viewController : UIViewController) -> Int {
        if let index = self.viewControllers?.firstIndex(of: viewController) {
            return index
        }
        
        return 0
    }
    
    func viewControllerAtIndex(_ index : Int) -> UIViewController? {
        if let vcs = viewControllers {
            if index >= vcs.count || index < 0 {
                return nil
            }
            return vcs[index]
        }
        return nil
    }
}

//MARK:- PageViewController DataSource
extension PageViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexForViewController(viewController)
        index = index - 1
        
        return viewControllerAtIndex(index)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexForViewController(viewController)
        index = index + 1
        
        return viewControllerAtIndex(index)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vcs = self.viewControllers {
            for i in 0..<vcs.count {
                if pendingViewControllers[0] == vcs[i] {
                    nextPageIndex = i
                    break
                }
            }
        }
    }
}

extension PageViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isPageScrollingFlag = true
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isPageScrollingFlag = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard buttons.count > currentPageIndex else {
            return
        }
        
        if isPageScrollingFlag {
            
            if scrollView.contentOffset.x <= 0 || scrollView.contentOffset.x >= scrollView.frame.size.width * 2 {
                let previousButton = buttons[currentPageIndex]
                previousButton.isSelected = false
                
                currentPageIndex = nextPageIndex
                
                let currentButton = buttons[currentPageIndex]
                currentButton.isSelected = true
                
                if let vc = viewControllers?[currentPageIndex], isContainSearchBar {
                    resetSearchBar(vc)
                }
            }
            
            animateIndicator(scrollView)
        }
    }
    
    private func isScrollViewBouncing(_ scrollView: UIScrollView) -> Bool {
        let minXOffset = scrollView.bounds.size.width - (CGFloat(self.currentPageIndex) * scrollView.bounds.size.width)
        let maxXOffset = CGFloat(numOfPageCount - self.currentPageIndex) * scrollView.bounds.size.width
        
        if scrollView.contentOffset.x <= minXOffset {
            scrollView.contentOffset = CGPoint(x: minXOffset, y: 0)
            return true
        } else if scrollView.contentOffset.x >= maxXOffset {
            scrollView.contentOffset = CGPoint(x: maxXOffset, y: 0)
            return true
        }
        return false
    }
    
    private func animateIndicator(_ scrollView: UIScrollView) {
        let xFromCenter: Int = Int(self.view.frame.size.width - scrollView.contentOffset.x)
        let width = SELECTOR_WIDTH
        
        let xCoor: CGFloat = CGFloat(X_BUFFER) + buttons[currentPageIndex].frame.origin.x
        let ratio: CGFloat = ((buttons[currentPageIndex].frame.size.width + buttons[nextPageIndex].frame.size.width) / 2) / self.view.frame.size.width
        
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
    
    private func pagingSegmentedControl() {
        if let segmentView = self.segmentedControlView, buttons.count > currentPageIndex {
            let targetButton = buttons[currentPageIndex]
            let outsideBound: Bool = (segmentView.contentOffset.x + segmentView.frame.size.width) <= targetButton.frame.maxX
                || segmentView.contentOffset.x > targetButton.frame.origin.x
            
            if outsideBound {
                segmentView.contentOffset = CGPoint(x: max(targetButton.frame.origin.x, 0), y: 0)
            }
        }
    }
}

extension String {
    func getTextWidth(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
}
