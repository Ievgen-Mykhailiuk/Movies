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
    private let buttonDiameter: CGFloat = 50
    private let buttonFontSize: CGFloat = 16
    private let buttonTitle: String = "Back"
    
    private lazy var scrollView: PosterScrollView = {
        let scrollView = PosterScrollView(image: poster)
        scrollView.frame = view.bounds
        return scrollView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: view.frame.midX - buttonDiameter / 2,
                                            y: view.frame.maxY - buttonDiameter * 2,
                                            width: buttonDiameter,
                                            height: buttonDiameter))
        let attributetText = NSAttributedString(
            string: buttonTitle,
            attributes: [.font: UIFont(name: Constants.appFont, size: buttonFontSize) as Any,
                         .foregroundColor: UIColor.lightGray as Any]
        )
        button.setAttributedTitle(attributetText, for: .normal)
        button.backgroundColor = .black.withAlphaComponent(0.7)
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
    
    //MARK: - Private methods
    private func setup() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        setupBackButton()
    }
    
    private func setupBackButton() {
        let tap = UITapGestureRecognizer(target: self, action:  #selector(close(_:)))
        backButton.addGestureRecognizer(tap)
        backButton.makeRounded()
        backButton.addShadow(color: UIColor.white.cgColor)
        view.addSubview(backButton)
    }

}

//MARK: - PosterViewProtocol
extension PosterViewController: PosterView {
    func showPoster() {
        setup()
    }
}
