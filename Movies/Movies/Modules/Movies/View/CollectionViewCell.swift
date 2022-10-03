//
//  CollectionViewCell.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit
import Kingfisher

final class CollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var releaseYearLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var genresTotalLabel: UILabel!
    @IBOutlet private weak var starImageView: UIImageView!
    @IBOutlet private weak var rankLabel: UILabel!
    @IBOutlet private weak var votesCountLabel: UILabel!
    
    
    //MARK: - Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        posterImageView.kf.cancelDownloadTask()
    }
    
    //MARK: - Configuration methods
    private func applyVisualEffects() {
        addShadow()
        posterImageView.layer.cornerRadius = 10
    }
    
    func configure(for movie: MovieModel, completion: @escaping ImageBlock) {
        titleLabel.text = movie.title
        releaseYearLabel.text = movie.releaseYear
        genresTotalLabel.text = movie.genres.joined(separator: ", ")
        rankLabel.text = movie.votesAverage
        votesCountLabel.text = movie.votesCount
        if let poster = movie.poster {
            posterImageView.image = poster
        } else {
            posterImageView.setImage(size: .small,
                                     endPoint: .poster(path: movie.posterPath),
                                     placeholder: nil) { image in
                completion(image)
            }
        }
        applyVisualEffects()
    }
}
