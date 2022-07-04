import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = .label
        showUnknown()
    }

    @IBOutlet
    private var statusImageView: UIImageView!

    private func showWiredEthernet() {
        view.backgroundColor = .systemGreen
        statusImageView.image = UIImage(systemName: "cable.connector")
    }

    private func showWiFi() {
        view.backgroundColor = .systemGreen
        statusImageView.image = UIImage(systemName: "wifi.circle.fill")
    }

    private func showCellular() {
        view.backgroundColor = .systemGreen
        statusImageView.image = UIImage(systemName: "antenna.radiowaves.left.and.right.circle.fill")
    }

    private func showDisconnected() {
        view.backgroundColor = .systemRed
        statusImageView.image = UIImage(systemName: "xmark.circle.fill")
    }

    private func showUnknown() {
        view.backgroundColor = .systemYellow
        statusImageView.image = UIImage(systemName: "questionmark.circle.fill")
    }

}
