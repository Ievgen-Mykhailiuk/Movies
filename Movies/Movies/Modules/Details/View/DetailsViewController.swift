//
//  DetailsViewController.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol DetailsView: AnyObject {
    func showPoster(with path: String)
    func showDetails(for movie: DetailsModel?)
    func showError(with message: String)
}

final class DetailsViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var bottomGradientView: UIView!
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
    private let gradientColorSet: [UIColor] = [.black.withAlphaComponent(1),
                                               .black.withAlphaComponent(0.9),
                                               .black.withAlphaComponent(0.8),
                                               .black.withAlphaComponent(0.7),
                                               .black.withAlphaComponent(0.6),
                                               .black.withAlphaComponent(0.5),
                                               .black.withAlphaComponent(0.4),
                                               .black.withAlphaComponent(0.3),
                                               .black.withAlphaComponent(0.2),
                                               .black.withAlphaComponent(0.1),
                                               .black.withAlphaComponent(0.05),
                                               .black.withAlphaComponent(0.02),
                                               .black.withAlphaComponent(0.01),
                                               .black.withAlphaComponent(0)]
    
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
        showLoadingView()
        showPoster(with: presenter.getPath())
        view.addGradient(with: [.white, .darkGray], startPoint: .bottomLeft, endPoint: .topRight)
        setRecognizers()
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
        bottomGradientView.isHidden = contentView.frame.height <= scrollView.frame.height
        posterImageView.isHidden ? nil : posterImageView.addShadow()
        playTrailerImageView.isHidden ? nil : playTrailerImageView.addShadow()
        bottomGradientView.isHidden ? nil : bottomGradientView.addGradient(with: gradientColorSet,
                                                                           startPoint: .bottomCenter,
                                                                           endPoint: .topCenter)
    }
    
    private func setPoster(with path: String) {
        guard !path.isEmpty else {
            posterImageView.isHidden = true
            return
        }
        let urlString = EndPoint.poster(size: .full, path: path).urlString
        posterImageView.setImage(urlString: urlString) { image in
            self.poster = image
        }
    }
    
    private func configure(by movie: DetailsModel?, completion: EmptyBlock? = nil) {
        guard let movie = movie else { return }
        countryLabel.text =  movie.countries.joined(separator: .commaSeparator)
        releaseYearLabel.text = movie.releaseYear
        movieNameLabel.text = movie.title
        genresLabel.text = movie.genres.joined(separator: .commaSeparator)
        rankLabel.text = movie.voteAverage.stringDecimalValue
        votesCountLabel.text = movie.voteCount.stringValue
        overviewLabel.text = movie.overview
        playTrailerImageView.isHidden = movie.trailerID == nil
        completion?()
    }
}

//MARK: - DetailsViewProtocol
extension DetailsViewController: DetailsView {
    func showPoster(with path: String) {
        setPoster(with: path)
    }
    
    func showError(with message: String) {
        showAlert(title: .defaultError, message: message)
    }
    
    func showDetails(for movie: DetailsModel?) {
        configure(by: movie) {
            DispatchQueue.main.async {
                self.applyVisualEffects()
            }
            self.hideLoadingView()
        }
    }
    
}
