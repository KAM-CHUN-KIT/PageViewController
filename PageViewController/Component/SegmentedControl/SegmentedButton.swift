//
//  SegmentedButton.swift
//  merchant-ios
//
//  Created by Kam on 27/11/2017.
//  Copyright © 2017 WWE & CO. All rights reserved.
//

import UIKit

class SegmentedButton: UIButton {
    
    var fontSize: CGFloat?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch self.state {
        case UIControl.State():
            if let size = fontSize {
                self.titleLabel?.font = UIFont.systemFont(ofSize: size)
            }
        case UIControl.State.selected:
            if let size = fontSize {
                self.titleLabel?.font = UIFont.boldSystemFont(ofSize: size+1)
            }
            break
        default:
            break
        }
    }
    
}
