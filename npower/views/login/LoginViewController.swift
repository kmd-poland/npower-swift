import UIKit
import PromiseKit

class LoginViewController: UIViewController {

    var coordinator: LoginCoordinatorProtocol?
    
  
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundView  = UIView()
        
        backgroundView.backgroundColor = UIColor.init(white: 1, alpha: 0.85)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.cornerRadius = 10.0
        containerView.addSubview(backgroundView)
        containerView.sendSubviewToBack(backgroundView)
        
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalToSystemSpacingAfter: backgroundView.leftAnchor, multiplier: 2),
            containerView.topAnchor.constraint(equalToSystemSpacingBelow: backgroundView.topAnchor, multiplier: 2),
            backgroundView.rightAnchor.constraint(equalToSystemSpacingAfter: containerView.rightAnchor, multiplier: 2),
            backgroundView.bottomAnchor.constraint(equalToSystemSpacingBelow: containerView.bottomAnchor, multiplier: 2)
            ])
        
        loginButton.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
    }


    @IBAction func loginButtonPressed(_ sender: Any) {
        coordinator?
                .logIn()
                .catch{err in print(err)}
    }

}
