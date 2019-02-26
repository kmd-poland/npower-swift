import Foundation
import PromiseKit
import UIKit
import Kingfisher

protocol AvatarImageProviderProtocol {
    func getAvatar(for url: URL) -> Promise<UIImage>
}
class AvatarImageProvider: AvatarImageProviderProtocol {

    private let cache = NSCache<NSString, UIImage>()

    func getAvatar(for url: URL) -> Promise<UIImage> {
        return  Promise<UIImage>{ seal in
            let processor = DownsamplingImageProcessor(size: CGSize(width: 60, height: 60))
                    >> RoundCornerImageProcessor(cornerRadius: 30, backgroundColor: .clear)

            
            KingfisherManager.shared.retrieveImage(
                    with: url,
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .cacheOriginalImage
                    ])
            {
                result in
                switch result {
                case .success(let value):
                   seal.fulfill(value.image)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
