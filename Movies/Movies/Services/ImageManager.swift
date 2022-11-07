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
    
    private init() {}
    
    func setImage(with urlString: String,
                  for imageView: UIImageView,
                  placeholder: UIImage?,
                  completion: ImageBlock? = nil) {
        
        if let url = URL(string: urlString) {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    if value.cacheType == .none, let imageData = value.image.jpegData(compressionQuality: 1) {
                        ImageCache.default.storeToDisk(imageData, forKey: urlString)
                    }
                    completion?(value.image)
                case .failure(_):
                    DispatchQueue.main.async {
                        imageView.image = placeholder
                    }
                    completion?(nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                imageView.image = placeholder
            }
            completion?(nil)
        }
    }
}
