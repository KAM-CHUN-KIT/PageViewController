//
//  Paging.swift
//  PageViewController
//
//  Created by Kam on 13/1/2021.
//  Copyright © 2021 Kam. All rights reserved.
//

import UIKit

protocol Paging {
    var numOfPageCount: Int { get }
    var currentPage: Int { get }
    var nextPage: Int { get }
    var buttonsWidth: CGFloat { get }
    
    func update(currentPage page: Int)
    func update(nextPage page: Int)
}
