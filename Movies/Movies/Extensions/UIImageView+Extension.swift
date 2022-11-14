//
//  UIImageView+Extension.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

extension UIImageView {
    
    func setImage(urlString: String,
                  placeholder: UIImage? = nil,
                  completion: ImageBlock? = nil) {
       
        ImageManager.shared.setImage(with: urlString,
                                     for: self,
                                     placeholder: placeholder,
                                     completion: completion)
    }
}
