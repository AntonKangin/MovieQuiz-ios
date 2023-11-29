
import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Overrides Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        showLoadingIndicator()
        
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - AlertPresenterProtocol
    func alertDidClose() {
        presenter?.restartGame()
        showLoadingIndicator()
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter?.yesButtonClicked()
    }
    
    // MARK: - Public Methods
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        buttonsIsEnabled(isEnabled: false)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        buttonsIsEnabled(isEnabled: true)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText)
        
        alertPresenter?.presentAlert(alert: alertModel, on: self)
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз")
        
        alertPresenter?.presentAlert(alert: alertModel, on: self)
    }
    
    // MARK: - Private Methods
    private func buttonsIsEnabled(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func setupView() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }
}
