//
//  DetailsViewController.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol DetailsView: AnyObject {
    func showDetails(movie: DetailModel?)
    func didFailWithError(error: String)
}

final class DetailsViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var trailerButton: UIButton!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var votesCountLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var presenter: DetailsPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    @IBAction func trailerButtonTapped(_ sender: Any) {
        
    }
    
    private func setupNavigationBar(title: String) {
        self.title = title
    }
    
    private func configure(movie: DetailModel?) {
        guard let movie = movie else { return }
        posterImageView.setImage(endPoint: .poster(path: movie.posterPath))
        countryLabel.text = movie.countries.joined(separator: ", ")
        movieNameLabel.text = movie.title
        genresLabel.text = movie.genres.joined(separator: ", ")
        releaseYearLabel.text = movie.releaseYear
        rankLabel.text = String(format: "%.1f", movie.voteAverage)
        votesCountLabel.text = String(movie.voteCount)
        overviewLabel.text = movie.overview
    }
}

extension DetailsViewController: DetailsView {
    func didFailWithError(error: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: error)
        }
    }
    
    func showDetails(movie: DetailModel?) {
        DispatchQueue.main.async {
            self.setupNavigationBar(title: movie?.title ?? .empty)
            self.configure(movie: movie)
        }
    }
}
