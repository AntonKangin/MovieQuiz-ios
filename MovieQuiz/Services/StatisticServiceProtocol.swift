
import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var totalCorrectAnswers: Int { get }
    var totalQuestions: Int { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct answersCount: Int, totalQuestion amount: Int)
}
