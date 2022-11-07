//
//  DetailsViewController.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol DetailsView: AnyObject {
    func showDetails(movie: DetailsModel?)
    func showError(with message: String)
}

final class DetailsViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var movieNameLabel: UILabel!
    @IBOutlet private weak var releaseYearLabel: UILabel!
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var playTrailerImageView: UIImageView!
    @IBOutlet private weak var rankLabel: UILabel!
    @IBOutlet private weak var votesCountLabel: UILabel!
    @IBOutlet private weak var overviewLabel: UILabel!
    
    //MARK: - Properties
    var presenter: DetailsPresenter!
    private var poster: UIImage?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        presenter.viewDidLoad()
    }
    
    //MARK: - Actions
    @objc private func trailerButtonTapped(_: UITapGestureRecognizer) {
        presenter.playTrailer()
    }
    
    @objc private func posterTapped(_: UITapGestureRecognizer) {
        guard let poster = poster else { return }
        presenter.showPoster(poster)
    }
    
    //MARK: - Private Methods
    private func initialSetup() {
        showLoadingView(indicatorColor: .lightGray, backgroundColor: Constants.appColor)
        view.addGradient(with: Constants.backgroundColorSet, startPoint: .bottomLeft, endPoint: .topRight)
        setRecognizers()
        playTrailerImageView.isHidden = true
    }
    
    private func setRecognizers() {
        let playTrailerRecognizer = UITapGestureRecognizer(target: self,
                                                           action: #selector(trailerButtonTapped(_:)))
        let showPosterRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(posterTapped(_:)))
        playTrailerImageView.addGestureRecognizer(playTrailerRecognizer)
        posterImageView.addGestureRecognizer(showPosterRecognizer)
    }
    
    private func applyVisualEffects() {
        posterImageView.isHidden ? nil : posterImageView.addShadow()
        playTrailerImageView.isHidden ? nil : playTrailerImageView.addShadow()
    }
    
    private func setPoster(for movie: DetailsModel, completion: @escaping EmptyBlock) {
        let urlString = EndPoint.poster(size: .full, path: movie.posterPath).urlString
        posterImageView.setImage(urlString: urlString) { image in
            self.poster = image
            self.posterImageView.isHidden = image == nil
            completion()
        }
    }
    
    private func configure(movie: DetailsModel?, completion: @escaping EmptyBlock) {
        guard let movie = movie else { return }
        setPoster(for: movie, completion: completion)
        countryLabel.text =  movie.countries.joined(separator: .commaSeparator)
        releaseYearLabel.text = movie.releaseYear
        movieNameLabel.text = movie.title
        genresLabel.text = movie.genres.joined(separator: .commaSeparator)
        rankLabel.text = movie.voteAverage.stringDecimalValue
        votesCountLabel.text = movie.voteCount.stringValue
        overviewLabel.text = movie.overview
        playTrailerImageView.isHidden = movie.trailerID == nil
        applyVisualEffects()
    }
}

//MARK: - DetailsViewProtocol
extension DetailsViewController: DetailsView {
    func showError(with message: String) {
        showAlert(title: .defaultError, message: message)
    }
    
    func showDetails(movie: DetailsModel?) {
        configure(movie: movie) {
            self.hideLoadingView()
        }
    }
}
