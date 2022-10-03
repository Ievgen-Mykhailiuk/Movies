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
}

