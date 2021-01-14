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
        options.segmentedTitles = ["Tab", "Tab With Long Title", "Tab", "Tab Tab", "Tab Showing in Half"] // YOUR [TITLEs]
        options.segmentedViewBackgroundColor = .white
        options.segmentButtonFontSize = 14  //YOUR FONT SIZE
        options.selectedTitleColor = .black // the button title color in selected / highlighed state
        options.deSelectedTitleColor = .lightGray // the button title color in normal state
        options.indicatorColor = .red // the indicator color
        
        let colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple]
        var vcs: [UIViewController] = []
        for color in colors {
            let vc = UIViewController()
            vc.view.backgroundColor = color
            vcs.append(vc)
        }
        
        let pageVC = ExampleViewController(viewControllers: vcs)
        self.pushViewController(pageVC, animated: false)
    }


}

