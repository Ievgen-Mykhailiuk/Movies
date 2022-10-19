//
//  UIViewController+Extension.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

extension UIViewController {
    
    var isModal: Bool {
        return presentingViewController != nil ||
        navigationController?.presentingViewController != nil
    }
    
    var loadingViewTag: Int { return 999999 }
    
    func showAlert(title: String?,
                   message: String?,
                   actions: [UIAlertAction]? = nil) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alert.addAction(action)
            }
        } else {
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default,
                                          handler: nil))
        }
        DispatchQueue.main.async {
            self.present(alert,
                         animated: true,
                         completion: nil)
        }
    }
    
    static func instantiateFromStoryboard(_ name: String = "Main") -> Self {
        return instantiateFromStoryboardHelper(name)
    }
    
    static func instantiateFromStoryboardHelper<T>(_ name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! T
        return controller
    }
    
    func showLoadingView(indicatorColor: UIColor?, backgroundColor: UIColor?) {
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = backgroundColor ?? .white
        backgroundView.tag = loadingViewTag
        let activityIndicator =  UIActivityIndicatorView(style: .large)
        activityIndicator.color = indicatorColor ?? .gray
        activityIndicator.center = backgroundView.center
        backgroundView.addSubview(activityIndicator)
        DispatchQueue.main.async {
            activityIndicator.startAnimating()
            self.view.addSubview(backgroundView)
        }
    }
    
    func hideLoadingView() {
        if let loadingView = self.view.viewWithTag(loadingViewTag) {
            DispatchQueue.main.async {
                loadingView.removeFromSuperview()
            }
        }
    }
    
}

