import Foundation
import PromiseKit
import UIKit
import Kingfisher

protocol AvatarImageProviderProtocol {
    func getAvatar(for url: URL, withSize: Int) -> Promise<UIImage>
}
class AvatarImageProvider: AvatarImageProviderProtocol {

    private let cache = NSCache<NSString, UIImage>()

    func getAvatar(for url: URL, withSize: Int = 60) -> Promise<UIImage> {
        return  Promise<UIImage>{ seal in
            let processor = DownsamplingImageProcessor(size: CGSize(width: withSize, height: withSize))
                    >> RoundCornerImageProcessor(cornerRadius: CGFloat(withSize/2), backgroundColor: .clear)

            
            KingfisherManager.shared.retrieveImage(
                    with: url,
                    options: [
                        .processor(processor),
                        .cacheSerializer(FormatIndicatedCacheSerializer.png),
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
