
import Foundation

class StatisticService: StatisticServiceProtocol {
    
    // MARK: - Public Properties
    var totalCorrectAnswers: Int {
        get { userDefaults.integer(forKey: Keys.totalCorrectAnswers.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue) }
    }
    
    var totalQuestions: Int {
        get { userDefaults.integer(forKey: Keys.totalQuestions.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.totalQuestions.rawValue) }
    }
    
    var totalAccuracy: Double {
        get { (Double(totalCorrectAnswers)/Double(totalQuestions)) * 100 }
    }
    
    var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case totalCorrectAnswers, totalQuestions, gamesCount, bestGame
    }
    
    // MARK: - Public Methods
    func store(correct answersCount: Int, totalQuestion amount: Int) {
        let currentGame = GameRecord(correct: answersCount, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
        totalCorrectAnswers += answersCount
        totalQuestions += amount
        gamesCount += 1
    }
}
