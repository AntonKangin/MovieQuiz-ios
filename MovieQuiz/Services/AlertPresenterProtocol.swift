
import UIKit

protocol AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate? { get set }
    func presentAlert(alert: AlertModel, on: UIViewController)
}
