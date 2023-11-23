
import UIKit

final class MovieQuizPresenter {
    
    // MARK: - Public Properties
    let questionAmount: Int = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    
    // MARK: - Public Methods
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
    
    func yesButtonClicked() {
        guard let currentQuestion else { return }
        let userAnswer = true
        
        viewController?.showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion else { return }
        let userAnswer = false
        
        viewController?.showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
}
