import Foundation
import Eureka
import RxSwift
import RxCocoa
import RxSwiftExt
import ViewModelOwners

class VisitViewController : FormViewController, NonReusableViewModelOwner {
    private var provider: AvatarImageProviderProtocol
    private var avatarImage: UIImage?
    
    let dataSection = Section()
    
    let pulse = IntRow{
        $0.title = "Pulse"
    }
    
    let systolic = IntRow {
        $0.title = "Systolic"
    }

    let diastolic = IntRow {
        $0.title = "Diastolic"
    }
    
    init(provider: AvatarImageProviderProtocol) {
        self.provider = provider
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didSetViewModel(_ viewModel: VisitViewModelProtocol, disposeBag: DisposeBag) {
        (pulse.rx.value <-> viewModel.pulse).disposed(by: disposeBag)
        (systolic.rx.value <-> viewModel.systolic).disposed(by: disposeBag)
        (diastolic.rx.value <-> viewModel.diastolic).disposed(by: disposeBag)
        
        if let avatarUrl = viewModel.avatar {
            self.provider.getAvatar(for: avatarUrl, withSize: 150)
                .done{ [unowned self] image in
                    self.avatarImage = image
                    self.dataSection.reload()
                }
                .catch{ err in print(err)}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var header = HeaderFooterView<UIImageView>(.class) // most flexible way to set up a header using any view type
        header.height = { 200 }
        header.onSetupView = { [unowned self] view, section in  // each time the view is about to be displayed onSetupView is invoked.
            view.image = self.avatarImage
            view.contentMode = .scaleAspectFit
        }
        dataSection.header = header
        
        self.form +++ dataSection
                  <<< pulse
                  <<< systolic
                  <<< diastolic
    }
}
