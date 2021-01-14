//
//  Scrolling.swift
//  PageViewController
//
//  Created by Kam on 13/1/2021.
//  Copyright © 2021 Kam. All rights reserved.
//

import UIKit

protocol Scrolling {
    func updateIsPageScrolling(_ isScrolling: Bool)
    func scroll(offset: CGPoint, percent: CGFloat)
}
