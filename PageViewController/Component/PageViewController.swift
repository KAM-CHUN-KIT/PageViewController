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

internal protocol PagerDelegate {
    func move(to nextPage: Int, completion: @escaping () -> ())
}

open class PageViewController: UIViewController {
    private var viewControllers: [UIViewController]?
    private var pageViewController: UIPageViewController?
    private var pageScrollView: UIScrollView?
    
    private var hasAppearedFlag = false
    
    private var segmentedControlView: SegmentedControlView?
    private var initialOffset: CGPoint = .zero
    
    init(viewControllers: [UIViewController]?) {
        super.init(nibName: nil, bundle: nil)
        
        guard let vcs = viewControllers else {
            print("**** No viewControllers was detected, please check your initializer****")
            return
        }
        let option = SegmentedControlOptions.default
        guard vcs.count == option.segmentedTitles.count else {
            print("**** viewControllers is not match with segmented titles count ****")
            return
        }
        self.viewControllers = vcs
        for (index, vc) in vcs.enumerated() {
            if let delegate = vc as? PageViewControllerDelegate {
                delegate.setIndex(index: index)
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasAppearedFlag, let _ = self.viewControllers { //will only setup UI with local data in willAppear
            self.reveal()
        }
        hasAppearedFlag = true
    }
    
    private func reveal() {
        self.segmentedControlView = SegmentedControlView(frame: CGRect(x: 0, y: SegmentedControlOptions.FrameConstant.SEGMENT_Y, width: self.view.frame.size.width, height: SegmentedControlOptions.FrameConstant.SEGMENT_HEIGHT))
        self.segmentedControlView?.pagerDelegate = self
        self.segmentedControlView?.update(pageWidth: self.view.frame.size.width)
        self.view.addSubview(self.segmentedControlView!)
        
        setupPageViewController(SegmentedControlOptions.default.navigateToTabIndex)
        
//        if navigateToTabIndex > 0 && self.buttons.count > navigateToTabIndex {
//            self.segmentButtonClicked(self.buttons[navigateToTabIndex])
//        }
        
        self.hasAppearedFlag = true
    }
    
    private func setupPageViewController(_ initialIndex: Int? = nil) {
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        guard let pageViewController = self.pageViewController else { return }
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        for view in pageViewController.view.subviews {
            if let scrollview = view as? UIScrollView {
                self.pageScrollView = scrollview
                scrollview.delegate = self
                break
            }
        }
        
        let startY = self.segmentedControlView?.frame.maxY ?? SegmentedControlOptions.FrameConstant.SEGMENT_Y + SegmentedControlOptions.FrameConstant.SEGMENT_HEIGHT
        
        pageViewController.view.frame = CGRect(x: 0, y: startY, width: view.frame.size.width, height: view.frame.maxY - startY)
        
        if let vcs = self.viewControllers, vcs.count > 0 {
            pageViewController.setViewControllers([vcs[initialIndex ?? 0]], direction: .forward, animated: true, completion: nil)
        }
        self.view.addSubview(pageViewController.view)
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
                    segmentedControlView?.update(nextPage: i)
                    break
                }
            }
        }
    }
}

extension PageViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.segmentedControlView?.updateIsPageScrolling(true)
        self.initialOffset = scrollView.contentOffset
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.segmentedControlView?.updateIsPageScrolling(false)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let percentage: CGFloat
        if initialOffset.x > scrollView.contentOffset.x {
            percentage = (initialOffset.x - scrollView.contentOffset.x)/self.view.frame.width
        }else {
            percentage = (scrollView.contentOffset.x - initialOffset.x)/self.view.frame.width
        }
        segmentedControlView?.scroll(offset: scrollView.contentOffset, percent: percentage)
    }
}

extension PageViewController: PagerDelegate {
    func move(to nextPage: Int, completion: @escaping () -> ()) {
        let currentPage = segmentedControlView?.currentPage ?? 0
        guard let vcs = self.viewControllers else { return }
        if vcs.count > nextPage {
            pageViewController?.setViewControllers([vcs[nextPage]], direction: nextPage > currentPage ? .forward : .reverse, animated: false, completion: { (complete) in
                if complete {
                    completion()
                }
            })
        }
    }
}
