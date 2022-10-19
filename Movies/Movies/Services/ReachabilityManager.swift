//
//  ReachabilityManager.swift
//  Movies
//
//  Created by Евгений  on 14/10/2022.
//

import Foundation
import Reachability

extension Notification.Name {
    static let networkStatusChanged = Notification.Name(rawValue: "networkStatusChanged")
}

final class ReachabilityManager {
    
    //MARK: - Singleton
    static let shared = ReachabilityManager()
    
    //MARK: - Properties
    private var reachability: Reachability?
    
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .unavailable
    }
    
    private var reachabilityStatus: Reachability.Connection = .unavailable {
        didSet {
            NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
        }
    }
    
    //MARK: - Private methods
    private func startNotifier() {
        reachability = try? Reachability()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(_:)),
                                               name: .reachabilityChanged,
                                               object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    private func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: .reachabilityChanged,
                                                  object: nil)
        reachability = nil
    }
    
    @objc private func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        if reachabilityStatus != reachability.connection {
            reachabilityStatus = reachability.connection
        }
    }
    
    //MARK: - Monitoring method
    func start() {
        stopNotifier()
        startNotifier()
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(5)) {
            self.start()
        }
    }
    
}



