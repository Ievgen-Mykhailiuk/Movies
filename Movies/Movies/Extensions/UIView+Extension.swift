//
//  UIView+Extension.swift
//  Movies
//
//  Created by Евгений  on 28/09/2022.
//

import UIKit

extension UIView {
    
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = newValue
        }
    }
    
    func makeRounded() {
        cornerRadius = frame.height/2
    }
    
    func addShadow(color: CGColor,
                   offset: CGSize = CGSize(width: 6.0, height: 4.0),
                   opacity: Float = 0.8,
                   radius: CGFloat = 2) {
    
        layer.shadowColor = color
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
