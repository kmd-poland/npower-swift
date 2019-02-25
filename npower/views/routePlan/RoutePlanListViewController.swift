import UIKit
import RxSwiftExt
import RxSwift
import Foundation
import ViewModelOwners
import Kingfisher

class RoutePlanListViewController: UITableViewController, NonReusableViewModelOwner {

    private let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
    
    private var visualEffectView: UIVisualEffectView?
    private var visits: [Visit]?
   
  
    
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
        
        if let avatarUrl = visit.avatar {
            visitCell.setAvatarUrl(avatarUrl)
        }
        visitCell.backgroundColor = .clear
       
        return cell
    }
}




