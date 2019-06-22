//
//  ExampleViewController.swift
//  PageViewControllerExample
//
//  Created by Kam on 22/6/2019.
//  Copyright © 2019 Kam. All rights reserved.
//

import UIKit

class ExampleViewController: PageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "KPageViewController"
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false
        self.dynamicWidthTab = true
        self.segmentedTitles = ["Tab", "Tab With Long Title", "Tab", "Tab Tab", "Tab Showing in Half"]
        
        let colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple]
        var vcs: [UIViewController] = []
        for color in colors {
            let vc = UIViewController()
            vc.view.backgroundColor = color
            vcs.append(vc)
        }
        self.viewControllers = vcs
        self.reveal()
    }
}
