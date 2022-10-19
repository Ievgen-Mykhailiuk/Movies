//
//  PosterViewController.swift
//  Movies
//
//  Created by Евгений  on 28/09/2022.
//

import UIKit

protocol PosterView: AnyObject {
    func showPoster(with path: String)
}

final class PosterViewController: UIViewController {
    
    //MARK: - Properties
    var presenter: PosterPresenter!
    private let minZoomScale: CGFloat = 1.0
    private let maxZoomScale: CGFloat = 10.0
    private let animationDuration: TimeInterval = 0.3
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
   
    private lazy var posterImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        presenter.viewDidLoad()
    }
    
    //MARK: - Action
    @objc private func handleSwipe(_ sender:UISwipeGestureRecognizer) {
        presenter.swiped()
    }

    //MARK: - Private methods
    private func initialSetup() {
        showLoadingView(indicatorColor: Constants.appShadowColor,
                        backgroundColor: Constants.appBackgroundColor)
        view.backgroundColor = Constants.appBackgroundColor
        setupScrollView()
        setupPosterImageView()
        setupSwipeRecognizer()
    }
    
    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.maximumZoomScale = maxZoomScale
        scrollView.minimumZoomScale = minZoomScale
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        view.addSubview(scrollView)
    }
    
    private func setupPosterImageView() {
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.frame = UIScreen.main.bounds
        scrollView.addSubview(posterImageView)
    }
    
    private func setupSwipeRecognizer() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
    }
}

//MARK: - PosterViewProtocol
extension PosterViewController: PosterView {
    func showPoster(with path: String) {
        let urlString = EndPoint.poster(size: .full, path: path).urlString
        posterImageView.setImage(urlString: urlString) {
            self.hideLoadingView()
        }
    }
}

//MARK: - UIScrollViewDelegate
extension PosterViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return posterImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: animationDuration, delay: .zero, options: []) {
            self.scrollView.zoomScale = self.minZoomScale
        }
    }
}
