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
    
    func addShadow(color: CGColor = UIColor.black.cgColor,
                   offset: CGSize = CGSize(width: 0, height: 0),
                   opacity: Float = 1,
                   radius: CGFloat = 5) {
        
        layer.shadowColor = color
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addGradient(with colorSet: [UIColor],
                     startPoint: GradientPoint,
                     endPoint: GradientPoint) {
        
        let gradientLayer = CAGradientLayer()
        let layerName = "gradient layer"
        gradientLayer.name = layerName
        gradientLayer.frame = bounds
        gradientLayer.colors = colorSet.compactMap({ $0.cgColor })
        gradientLayer.startPoint = startPoint.point
        gradientLayer.endPoint = endPoint.point
        layer.sublayers?.filter({ $0.name == layerName }).forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradientLayer, at:0)
    }
    
}
