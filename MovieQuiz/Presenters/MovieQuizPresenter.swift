
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private Properties
    private let statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionAmount: Int = 10
    
    // MARK: - Initializers
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Public Methods
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func yesButtonClicked() {
        didAnswer(userAnswer: true)
    }
    
    func noButtonClicked() {
        didAnswer(userAnswer: false)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
    
    // MARK: - Private Methods
    private func didAnswer(userAnswer: Bool) {
        guard let currentQuestion else { return }
        
        var isCorrectAnswer: Bool { userAnswer == currentQuestion.correctAnswer }
        if isCorrectAnswer { correctAnswers += 1 }
        
        showAnswerResult(isCorrect: isCorrectAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultsMessage(),
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            viewController?.showLoadingIndicator()
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func makeResultsMessage() -> String {
        statisticService?.store(correct: correctAnswers, totalQuestion: questionAmount)
        
        let totalAccuracy = statisticService?.totalAccuracy ?? (Double(correctAnswers)/Double(questionAmount)) * 100
        let bestGame = statisticService?.bestGame
        
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService?.gamesCount ?? 1)"
        let bestGameInfoLine = "Рекорд: \(bestGame?.correct ?? correctAnswers)/\(bestGame?.total ?? questionAmount) (\(bestGame?.date.dateTimeString ?? Date().dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        viewController?.show(quiz: viewModel)
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}
