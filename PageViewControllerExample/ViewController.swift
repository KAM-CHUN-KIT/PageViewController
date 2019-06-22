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
        self.pushViewController(ExampleViewController(), animated: false)
    }


}

