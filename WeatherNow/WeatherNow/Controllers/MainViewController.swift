import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackground()
        configureSubviews()
    }
    
    // MARK: - Configuration -
    
    func configureBackground() {
        view.backgroundColor = UIColor.lightText
    }
    
    func configureSubviews() {
        configureLabels()
        configureTextView()
        configureButton()
    }
    
    func configureLabels() {
        titleLabel.backgroundColor = UIColor.clear
        subtitleLabel.backgroundColor = UIColor.clear
    }
    
    func configureTextView() {
        resultTextView.backgroundColor = UIColor.clear
    }
    
    func configureButton() {
        recordButton.backgroundColor = UIColor.red
        recordButton.layer.cornerRadius = recordButton.frame.size.width / 2
        recordButton.setTitleColor(UIColor.white, for: UIControlState.normal)
    }

    // MARK: - Actions -
    
    @IBAction func recordPressed(_ sender: Any) {
    }
    
}
