//
//  ImageManager.swift
//  Movies
//
//  Created by Евгений  on 11/10/2022.
//

import UIKit
import Kingfisher

final class ImageManager {
    
    static let shared = ImageManager()
    
    func setImage(with urlString: String,
                  for imageView: UIImageView,
                  placeholder: UIImage?,
                  completion: EmptyBlock? = nil) {
       
        if let url = URL(string: urlString) {
            KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
                switch result {
                case .success(let value):
                    switch value.cacheType {
                    case .disk, .memory:
                        imageView.image = value.image
                    case .none:
                        imageView.image = value.image
                        if let imageData = value.image.pngData() {
                            ImageCache.default.storeToDisk(imageData, forKey: urlString)
                        }
                    }
                case .failure(_):
                    imageView.image = placeholder
                }
                completion?()
            }
        } else {
            imageView.image = placeholder
            completion?()
        }
    }
    
}
