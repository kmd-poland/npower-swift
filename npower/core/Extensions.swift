import Foundation
import RxSwift
import ViewModelOwners

extension DisposeBag: ViewModelOwnerDisposeBagProtocol {
    private final class DisposableWrapper: Disposable {
        let disposable: ViewModelOwnerDisposable

        init(_ disposable: ViewModelOwnerDisposable) {
            self.disposable = disposable
        }

        func dispose() {
            disposable.dispose()
        }
    }

    public func add(_ disposable: ViewModelOwnerDisposable) {
        insert(DisposableWrapper(disposable))
    }
}
