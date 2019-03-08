import Foundation
import RxSwift
import ViewModelOwners
import Eureka
import RxCocoa
import RxSwiftExt

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

extension RowOf: ReactiveCompatible {}

extension Reactive where Base: RowType, Base: BaseRow {
    var value: ControlProperty<Base.Cell.Value?> {
        let source = Observable<Base.Cell.Value?>.create { observer in
            self.base.onChange { row in
                observer.onNext(row.value)
            }
            return Disposables.create()
        }
        let bindingObserver = Binder(self.base) { (row, value) in
            row.value = value
        }
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}

infix operator <->

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.value = n
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return  CompositeDisposable(disposables: [bindToUIDisposable, bindToVariable])
}
