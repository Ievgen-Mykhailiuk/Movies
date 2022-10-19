//
//  SceneDelegate.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private func setup(_ scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let view = DefaultMoviesAssembly().createMoviesModule()
        window?.rootViewController = view
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        setup(scene)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        DefaultCoreDataService.shared.saveContext()
    }
}
