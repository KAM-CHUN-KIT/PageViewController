//
//  PageViewControllerTests.swift
//  PageViewControllerTests
//
//  Created by Kam on 22/6/2019.
//  Copyright © 2019 Kam. All rights reserved.
//

import XCTest
@testable import PageViewController

class PageViewControllerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIndexForViewController() {
        let options: SegmentedControlOptions = SegmentedControlOptions()
        options.segmentedTitles = ["1", "2", "3", "4", "5"]
        
        let colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple]
        var vcs: [UIViewController] = []
        for color in colors {
            let vc = UIViewController()
            vc.view.backgroundColor = color
            vcs.append(vc)
        }
        let testIndex = 2
        let viewControllerToBeTested: UIViewController = vcs[testIndex]
        let pageVC = PageViewController(viewControllers: vcs, options: options)
        XCTAssert(pageVC.indexForViewController(viewControllerToBeTested) == testIndex)
    }
    
    func testViewControllerAtIndex() {
        let options: SegmentedControlOptions = SegmentedControlOptions()
        options.segmentedTitles = ["1", "2", "3", "4", "5"]
        
        let colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple]
        var vcs: [UIViewController] = []
        for color in colors {
            let vc = UIViewController()
            vc.view.backgroundColor = color
            vcs.append(vc)
        }
        let testIndex = 3
        let viewControllerToBeTest: UIViewController = vcs[testIndex]
        let pageVC = PageViewController(viewControllers: vcs, options: options)
        XCTAssert(pageVC.viewControllerAtIndex(testIndex) == viewControllerToBeTest)
    }
}
