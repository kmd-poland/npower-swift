import UIKit
import RxSwiftExt
import RxSwift
import Foundation
import ViewModelOwners
import Kingfisher

class RoutePlanListViewController: UITableViewController, NonReusableViewModelOwner {

    private let avatarProvider: AvatarImageProviderProtocol
    private weak var coordinator: MainCoordinator?
    
    private let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
    
    private var visualEffectView: UIVisualEffectView?
    private var visits: [Visit]?
   
    init(_ avatarProvider: AvatarImageProviderProtocol, coordinator: MainCoordinator) {
        self.coordinator = coordinator
        self.avatarProvider = avatarProvider
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        tableView.backgroundView = visualEffectView

        tableView.register(VisitTableViewCell.self, forCellReuseIdentifier: "VisitTableViewCell")
        
        self.visualEffectView = visualEffectView
    }
    func didSetViewModel(_ viewModel: RoutePlanViewModelProtocol, disposeBag: DisposeBag) {
        viewModel
                .visits
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [unowned self] (value) in
                   self.visits = value
                    self.tableView.reloadData()
                })
                .disposed(by: disposeBag)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visits?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VisitTableViewCell", for: indexPath)
        let visitAtRow = visits?[indexPath.row]
        guard let visit = visitAtRow, let visitCell = cell as? VisitTableViewCell else {
            return cell
        }
       
        visitCell.titleLabel.text = "\(timeFormatter.string(from: visit.startTime)) \(visit.firstName ?? "") \(visit.lastName ?? "")"
        visitCell.subtitleLabel.text = visit.address
        
        if let avatarUrlString = visit.avatar, let avatarUrl = URL(string: avatarUrlString) {
            visitCell.imageTag = avatarUrlString
            self
                .avatarProvider
                .getAvatar(for: avatarUrl, withSize: 60)
                .done{[unowned visitCell] img in
                    if visitCell.imageTag == avatarUrlString {
                        visitCell.avatarImageView.image = img
                    }
                }.catch{
                    print($0)
                }
        }
        
        visitCell.backgroundColor = .clear
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let visit = self.visits?[indexPath.row] {
            self.coordinator?.showVisit(visit)
        }
    }
}




