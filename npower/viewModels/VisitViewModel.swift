import RxSwift
import Foundation


protocol VisitViewModelProtocol {
    var avatar: URL? { get }
    var pulse: Variable<Int?> { get}
    var systolic: Variable<Int?> { get }
    var diastolic: Variable<Int?> { get }
}

class VisitViewModel: VisitViewModelProtocol{
    weak private var coordinator: MainCoordinator!
    private let visit: Visit!
    
    let avatar: URL?
    let pulse: Variable<Int?> = Variable<Int?>(nil)
    let systolic: Variable<Int?> = Variable<Int?>(120)
    let diastolic: Variable<Int?> = Variable<Int?>(nil)
    
    init(visit: Visit, coordinatedBy: MainCoordinator) {
        self.coordinator = coordinatedBy
        self.visit = visit
        if let avatarUrl = self.visit?.avatar {
            self.avatar = URL(string: avatarUrl)
        } else
        {
            self.avatar = nil
        }
     
    }
    
}

