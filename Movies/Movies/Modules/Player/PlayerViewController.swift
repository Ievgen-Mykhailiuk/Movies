//
//  PlayerViewController.swift
//  Movies
//
//  Created by Евгений  on 10/11/2022.
//

import UIKit
import YouTubeiOSPlayerHelper

//MARK: - Protocol
protocol PlayerView: AnyObject {
    func playTrailer(with id: String)
}

final class PlayerViewController: UIViewController {
   
    // MARK: - Properties
    var presenter: PlayerPresenter!
    private let buttonDiameter: CGFloat = 40
    private let playerViewHeight: CGFloat = 400
    
    private lazy var playerView: YTPlayerView = {
        let playerView = YTPlayerView(frame: CGRect(x: .zero,
                                                    y: view.frame.midY - playerViewHeight / 2,
                                                    width: view.frame.width,
                                                    height: playerViewHeight))
        return playerView
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
        
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        presenter.viewDidLoad()
    }
    
    //MARK: - Action
    @objc private func close(_ sender:UISwipeGestureRecognizer) {
        presenter.close()
    }
    
    // MARK: - Private Methods
    private func initialSetup() {
        showLoadingView()
        playerView.delegate = self
        setupBackButton()
        view.addSubview(playerView)
    }
    
    private func setupBackButton() {
        let tap = UITapGestureRecognizer(target: self, action:  #selector(close(_:)))
        closeButton.addGestureRecognizer(tap)
        view.addSubview(closeButton)
    }
    
}

// MARK: - PlayerView
extension PlayerViewController: PlayerView {
    func playTrailer(with id: String) {
        playerView.load(withVideoId: id)
    }
}

// MARK: - YTPlayerViewDelegate
extension PlayerViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        hideLoadingView()
    }
}
