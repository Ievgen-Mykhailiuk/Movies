//
//  BaseRouter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol BaseModuleRouter: AnyObject {
    func show(viewController: UIViewController,
              isModal: Bool,
              animated: Bool,
              completion: EmptyBlock?)
    
    func close(animated: Bool,
               completion: EmptyBlock?)
    
    func goBack(to viewController: UIViewController,
                animated: Bool,
                completion: EmptyBlock?)
}

class BaseRouter: BaseModuleRouter {
    
    //MARK: - Properties
    private let viewController: UIViewController
    private var navigationController: UINavigationController?  {
        return viewController.navigationController
    }
    
    //MARK: - Life Cycle
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    //MARK: - Base protocol methods
    func show(viewController: UIViewController,
              isModal: Bool,
              animated: Bool,
              completion: EmptyBlock? = nil) {
        let presentingViewController = navigationController ?? self.viewController
        if isModal {
            presentingViewController.present(viewController,
                                             animated: animated,
                                             completion: completion)
        } else {
            navigationController?.pushViewController(viewController,
                                                     animated: animated,
                                                     completion: completion)
        }
    }
    
    func close(animated: Bool,
               completion: EmptyBlock? = nil) {
        if viewController.isModal {
            if let navigationController = navigationController {
                navigationController.dismiss(animated: animated,
                                             completion: completion)
            } else {
            viewController.dismiss(animated: animated,
                                   completion: completion)
            }
        } else {
            navigationController?.popViewController(animated: animated,
                                                    completion: completion)
        }
    }
    
    func goBack(to viewController: UIViewController,
                animated: Bool,
                completion: EmptyBlock? = nil) {
        navigationController?.popToViewController(viewController,
                                                  animated: animated,
                                                  completion: completion)
    }
}
