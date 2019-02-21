import AuthenticationServices
import Foundation
import PromiseKit

var webAuthSession: ASWebAuthenticationSession?

protocol AuthenticationServiceProtocol {
    func isUserLoggedIn() -> Bool
    func getAuthTokenWithWebLogin() -> Promise<String>
}

enum AuthenticationError: Error {
    case requestFailure
    case responseFailure
}

class AuthenticationService: AuthenticationServiceProtocol {

    var authToken: String?
    var webAuthSession: ASWebAuthenticationSession?


    func isUserLoggedIn() -> Bool {
        return authToken != nil
    }

    func getAuthTokenWithWebLogin() -> Promise<String> {

        if let authToken = self.authToken {
            return Promise.value(authToken)
        }

        let callbackUrlScheme = "com.oktapreview.dev-910575"

        var authUrlBuilder = URLComponents(string: "https://dev-910575.oktapreview.com/oauth2/default/v1/authorize")
        authUrlBuilder?.queryItems = [
            URLQueryItem(name: "client_id", value: "0oajedfmef0ijCd6s0h7"),
            URLQueryItem(name: "scope", value: "openid"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "redirect_uri", value: "com.oktapreview.dev-910575:/callback"),
            URLQueryItem(name: "nonce", value: UUID().uuidString),
            URLQueryItem(name: "state", value: UUID().uuidString)
        ]

        return Promise { seal in
            guard let authUrl = authUrlBuilder?.url else {
                seal.reject(AuthenticationError.requestFailure)
                return
            }

            self.webAuthSession = ASWebAuthenticationSession.init(
                    url: authUrl,
                    callbackURLScheme: callbackUrlScheme,
                    completionHandler: { (callBack: URL?, error: Error?) in

                        // handle auth response
                        guard error == nil, let successURL = callBack else {
                            seal.resolve(error, nil)
                            return
                        }

                        var components =  URLComponents()
                        components.query = successURL.fragment
            
                        let oauthToken =
                                components
                                        .queryItems?
                                        .filter({ $0.name == "access_token" }).first

                        guard let token = oauthToken?.value else {
                            seal.reject(AuthenticationError.responseFailure)
                            return
                        }

                        seal.fulfill(token)
                    })

            self.webAuthSession?.start()

        }

    }
}
