
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory()
        questionFactory?.delegate = self
        questionFactory?.requestNextQuestion()
        
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        
        statisticService = StatisticService()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterProtocol
    func alertDidClose() {
        correctAnswers = 0
        currentQuestionIndex = 0
        
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion else { return }
        let userAnswer = true
        
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion else { return }
        let userAnswer = false
        
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        noButton.isEnabled = true
        yesButton.isEnabled = true
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect { correctAnswers += 1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questionAmount - 1 {
            
            statisticService?.store(correct: correctAnswers, totalQuestion: questionAmount)
            
            let totalAccuracy = statisticService?.totalAccuracy ?? (Double(correctAnswers)/Double(questionAmount)) * 100
            let message = """
                Ваш результат: \(correctAnswers)/\(questionAmount)
                Количество сыграных квизов: \(statisticService?.gamesCount ?? 1)
                Рекорд: \(statisticService?.bestGame.correct ?? correctAnswers)/\(statisticService?.bestGame.total ?? questionAmount) (\(statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString))
                Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                """
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть ещё раз")
            
            alertPresenter?.presentAlert(alert: alertModel, on: self)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
