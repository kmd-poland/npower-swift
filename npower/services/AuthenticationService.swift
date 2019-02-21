//
// Created by Czechowski.Maciej MCZ on 2019-02-21.
// Copyright (c) 2019 kmdpoland. All rights reserved.
//

import Foundation

protocol AuthenticationServiceProtocol{
    func isUserLoggedIn() -> Bool
}

class AuthenticationService : AuthenticationServiceProtocol {
    func isUserLoggedIn() -> Bool {
        return false
    }
}