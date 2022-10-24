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
    
    //MARK: - Properties
    private let radius: CGFloat = 10
    
    //MARK: - Private methods
    private func applyVisualEffects() {
        posterImageView.cornerRadius = radius
        contentView.cornerRadius = radius
        addShadow(color: Constants.appShadowColor?.cgColor ?? UIColor.white.cgColor)
    }
    
    private func setPoster(for movie: MovieModel) {
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        let urlString = EndPoint.poster(size: .small, path: movie.posterPath).urlString
        let placeholder = Constants.placeholder
        posterImageView.setImage(urlString: urlString, placeholder: placeholder)
    }
    
    //MARK: - Configuration method
    func configure(for movie: MovieModel) {
        setPoster(for: movie)
        titleLabel.text = movie.title
        releaseYearLabel.text = movie.releaseYear
        genresTotalLabel.text = movie.genres.joined(separator: .comaSeparator)
        rankLabel.text = movie.votesAverage
        votesCountLabel.text = movie.votesCount
        applyVisualEffects()
    }
}
