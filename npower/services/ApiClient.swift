import Foundation
import RxSwift
import RxCocoa

enum ApiError : Error {
    case urlMalformed
}

protocol ApiClientProtocol {
    func getAndDecodeJsonResponse<T: Decodable>(toType: T.Type, from url: URL,
                                                queryParameters: [String: String]) -> Observable<T>
    func getRawData(for url:URL) -> Observable<Data>
}

class ApiClient: ApiClientProtocol {

    func getAndDecodeJsonResponse<T>(toType: T.Type,
                                from url: URL,
                                queryParameters: [String: String] = [:])
                    -> Observable<T> where T: Decodable {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return Observable<T>.error(ApiError.urlMalformed)
        }

        if !queryParameters.isEmpty {
            components.queryItems = queryParameters.map { queryParameter in
                return URLQueryItem(name: queryParameter.key, value: queryParameter.value)
            }
        }

        guard let url = components.url else {
            return Observable<T>.error(ApiError.urlMalformed)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return URLSession.shared
                .rx
                .data(request: request)
                .map { data in
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let model: T = try decoder.decode(T.self, from: data)
                    return model
                }
    }

    func getRawData(for url:URL) -> Observable<Data> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return URLSession.shared
                .rx
                .data(request: request)
                .map { data in
                    return data
                }
    }
}
