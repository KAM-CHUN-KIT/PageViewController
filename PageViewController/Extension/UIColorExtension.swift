//
//  UIColorExtension.swift
//  PageViewController
//
//  Created by Kam on 22/6/2019.
//  Copyright © 2019 Kam. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {
    
    class func colorBetween(_ startColor: UIColor, destinationColor: UIColor, fraction: CGFloat) -> UIColor {
        var f = max(0, fraction)
        f = min(1, fraction)
        
        let startComponent = startColor.getComponents()
        let destinationComponent = destinationColor.getComponents()
        
        let red = startComponent.red + (destinationComponent.red - startComponent.red) * f
        let green = startComponent.green + (destinationComponent.green - startComponent.green) * f
        let blue = startComponent.blue + (destinationComponent.blue - startComponent.blue) * f
        let alpha = startComponent.alpha + (destinationComponent.alpha - startComponent.alpha) * f
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private func getComponents() -> ColorComponents {
        if (self.cgColor.numberOfComponents == 2) {
            let cc = self.cgColor.components
            return ColorComponents(red: cc![0], green: cc![0], blue: cc![0], alpha: cc![1])
        }
        else {
            let cc = self.cgColor.components
            return ColorComponents(red: cc![0], green: cc![1], blue: cc![2], alpha: cc![3])
        }
    }
    
    private struct ColorComponents {
        var red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat
    }
}
