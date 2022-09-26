//
//  CollectionViewCell.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

final class CollectionViewCell: BaseCollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var releaseYearLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var genresTotalLabel: UILabel!
    @IBOutlet private weak var starImageView: UIImageView!
    @IBOutlet private weak var rankLabel: UILabel!
    @IBOutlet private weak var votesCountLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
    }
    
    func configure(movie: MovieModel) {
        titleLabel.text = movie.title
        releaseYearLabel.text = String(movie.releaseYear)
        if let path = movie.posterPath {
            posterImageView.setImage(endPoint: .poster(path: path))
        }
        genresTotalLabel.text = movie.genres.joined(separator: ", ")
        rankLabel.text = String(format: "%.1f", movie.voteAverage)
        votesCountLabel.text = String(movie.voteCount)
    }
}
