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
        
        let options: SegmentedControlOptions = SegmentedControlOptions()
        options.segmentedTitles = ["Tab", "Tab With Long Title", "Tab", "Tab Tab", "Tab Showing in Half"] // YOUR [TITLEs]
        options.segmentButtonFontSize = 14  //YOUR FONT SIZE
        
        let colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple]
        var vcs: [UIViewController] = []
        for color in colors {
            let vc = UIViewController()
            vc.view.backgroundColor = color
            vcs.append(vc)
        }
        
        let pageVC = ExampleViewController(viewControllers: vcs, options: options)
        self.pushViewController(pageVC, animated: false)
    }


}

