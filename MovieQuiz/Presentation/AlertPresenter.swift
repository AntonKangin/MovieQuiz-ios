
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    // MARK: - Public Properties
    weak var delegate: AlertPresenterDelegate?
    
    // MARK: - Public Methods
    func presentAlert(alert: AlertModel, on viewController: UIViewController) {
        
        let controller = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert)
        
        controller.view.accessibilityIdentifier = "Alert"
        
        let action = UIAlertAction(
            title: alert.buttonText,
            style: .default,
            handler: { [weak self] _ in
                self?.delegate?.alertDidClose()
            })
        
        controller.addAction(action)
        viewController.present(controller, animated: true)
    }
}
