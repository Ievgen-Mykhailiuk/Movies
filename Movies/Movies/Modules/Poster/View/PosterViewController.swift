//
//  PosterViewController.swift
//  Movies
//
//  Created by Евгений  on 28/09/2022.
//

import UIKit

protocol PosterView: AnyObject {
    func showPoster()
}

final class PosterViewController: UIViewController {
    
    //MARK: - Properties
    var presenter: PosterPresenter!
    private let poster: UIImage
    private let buttonDiameter: CGFloat = 40
    
    private lazy var scrollView: PosterScrollView = {
        let scrollView = PosterScrollView(image: poster)
        scrollView.frame = view.bounds
        return scrollView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: view.frame.width - buttonDiameter * 1.5,
                                            y: buttonDiameter * 1.5,
                                            width: buttonDiameter,
                                            height: buttonDiameter))
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .white.withAlphaComponent(0.2)
        button.makeRounded()
        return button
    }()

    //MARK: - Life Cycle
    init(poster: UIImage) {
        self.poster = poster
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPoster()
    }
    
    //MARK: - Action
    @objc private func close(_ sender:UISwipeGestureRecognizer) {
        presenter.close()
    }
    
    @objc private func handleSwipe(_ sender:UISwipeGestureRecognizer) {
        presenter.close()
    }
    
    //MARK: - Private methods
    private func setup() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        setupCloseButton()
        setupSwipeRecognizer()
    }
    
    private func setupCloseButton() {
        let tap = UITapGestureRecognizer(target: self, action:  #selector(close(_:)))
        closeButton.addGestureRecognizer(tap)
        view.addSubview(closeButton)
    }
    
    private func setupSwipeRecognizer() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
    }
}

//MARK: - PosterViewProtocol
extension PosterViewController: PosterView {
    func showPoster() {
        setup()
    }
}
