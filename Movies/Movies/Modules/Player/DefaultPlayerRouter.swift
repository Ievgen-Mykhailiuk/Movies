//
//  File.swift
//  Movies
//
//  Created by Евгений  on 10/11/2022.
//

import Foundation

// MARK: - Protocol
protocol PlayerRouter {
    func close()
}

final class DefaultPlayerRouter: BaseRouter, PlayerRouter {
    func close() {
        close(animated: true)
    }
}
