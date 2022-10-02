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
        presenter.getPoster()
    }
    
    //MARK: - Action
    @objc func handleSwipe(_ sender:UISwipeGestureRecognizer) {
        presenter.posterSwiped()
    }
    
    //MARK: - Private methods
    private func initialSetup() {
        scrollView.delegate = self
        view.backgroundColor = .white
        setupScrollView()
        setupPosterImageView()
        setSwipeRecognizer()
    }
    
    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.maximumZoomScale = 10.0
        scrollView.minimumZoomScale = 1.0
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
    
    private func setSwipeRecognizer() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
    }
}

//MARK: - PosterViewProtocol
extension PosterViewController: PosterView {
    func showPoster(with path: String) {
        self.posterImageView.setImage(size: .full, endPoint: .poster(path: path))
    }
}

//MARK: - UIScrollViewDelegate
extension PosterViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return posterImageView
    }
}
