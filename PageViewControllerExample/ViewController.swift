//
//  ViewController.swift
//  PageViewControllerExample
//
//  Created by Kam on 22/6/2019.
//  Copyright © 2019 Kam. All rights reserved.
//

import UIKit

class ViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = SegmentedControlOptions.default
        options.segmentedTitles = ["Home", "TV Shows", "Home", "TV Shows", "Home", "TV Shows"] // YOUR [TITLEs]
        options.segmentedViewBackgroundColor = .yellow
        options.segmentButtonFont = UIFont.systemFont(ofSize: 14)  //YOUR FONT
        options.selectedTitleColor = .red // the button title color in selected / highlighed state
        options.deSelectedTitleColor = .lightGray // the button title color in normal state
        options.indicatorColor = .red // the indicator color
        
        let colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple]
        var vcs: [UIViewController] = []
        for i in 0..<options.segmentedTitles.count {
            let vc = UIViewController()
            vc.view.backgroundColor = colors[i % colors.count]
            vcs.append(vc)
        }
        
        let pageVC = ExampleViewController(viewControllers: vcs)
        self.pushViewController(pageVC, animated: false)
    }


}

