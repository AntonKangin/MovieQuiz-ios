
import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    // MARK: - Public Properties
    weak var delegate: QuestionFactoryDelegate?
    
    // MARK: - Private Properties
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    // MARK: - Initializers
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // MARK: - Public Methods
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard
                let self = self,
                let index = (0..<self.movies.count).randomElement(),
                let movie = self.movies[safe: index]
            else {
                return
            }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let randomRating = round(Float.random(in: (8.1...8.7)) * 10) / 10
            let randomComparison = Bool.random()
            
            var text: String {
                return randomComparison ? "Рейтинг этого фильма больше чем \(randomRating)?" :
                "Рейтинг этого фильма меньше чем \(randomRating)?"
            }
            
            var correctAnswer: Bool {
                return randomComparison ? rating > randomRating : rating < randomRating
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
