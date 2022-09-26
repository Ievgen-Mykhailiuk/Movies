//
//  UIImageView+Extension.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(endPoint: EndPoint,
                  placeholder: UIImage? = nil,
                  completion: ImageBlock? = nil) {
        guard let url = endPoint.url else {
            completion?(nil)
            return
        }
        self.kf.indicatorType = .activity
        let processor = DownsamplingImageProcessor(size: CGSize(width: 200, height: 350))
        self.kf.setImage(with: url,
                         placeholder: placeholder,
                         options: [.fromMemoryCacheOrRefresh, .processor(processor)],
                         progressBlock: nil) { result in
            switch result {
            case .success(let imageResult):
                completion?(imageResult.image)
            case .failure(_):
                completion?(nil)
            }
        }
    }
}
