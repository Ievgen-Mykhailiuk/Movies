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
    @IBOutlet private weak var countryLabel: UILabel!
    @IBOutlet private weak var releaseYearLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var trailerButton: UIButton!
    @IBOutlet private weak var rankLabel: UILabel!
    @IBOutlet private weak var votesCountLabel: UILabel!
    @IBOutlet private weak var overviewLabel: UILabel!
    
    //MARK: - Properties
    var presenter: DetailsPresenter!
    private let radius: CGFloat = 10

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        presenter.viewDidLoad()
    }
    
    //MARK: - Actions
    @IBAction private func trailerButtonTapped(_ sender: Any) {
        presenter.playTrailer()
    }
    
    @objc private func imageTapped(_: UITapGestureRecognizer) {
        presenter.showPoster()
    }
    
    //MARK: - Private Methods
    private func initialSetup() {
        showLoadingView(indicatorColor: Constants.appShadowColor,
                        backgroundColor: Constants.appBackgroundColor)
        setupTrailerButton()
        setRecognizer()
    }

    private func setupTrailerButton() {
        trailerButton.makeRounded()
        trailerButton.backgroundColor = Constants.appShadowColor
        trailerButton.isHidden = true
    }
    
    private func setRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        posterImageView.isUserInteractionEnabled = true
        posterImageView.addGestureRecognizer(recognizer)
    }
    
    private func setPoster(for movie: DetailsModel) {
        let urlString = EndPoint.poster(size: .small, path: movie.posterPath).urlString
        let placeholder = Constants.placeholder
        posterImageView.setImage(urlString: urlString, placeholder: placeholder)
        posterImageView.cornerRadius = radius
    }

    private func configure(movie: DetailsModel?) {
        guard let movie = movie else { return }
        setPoster(for: movie)
        countryLabel.text = movie.countries.joined(separator: .comaSeparator)
        movieNameLabel.text = movie.title
        genresLabel.text = movie.genres.joined(separator: .comaSeparator)
        releaseYearLabel.text = movie.releaseYear
        rankLabel.text = movie.voteAverage.stringDecimalValue
        votesCountLabel.text = movie.voteCount.stringValue
        overviewLabel.text = movie.overview
        trailerButton.isHidden = movie.trailerID == nil
    }
}

//MARK: - DetailsViewProtocol
extension DetailsViewController: DetailsView {
    func showError(with message: String) {
        showAlert(title: .defaultError, message: message)
    }
    
    func showDetails(movie: DetailsModel?) {
        configure(movie: movie)
        hideLoadingView()
    }
}
