import Foundation

enum DictionaryClientError: Error {
    case parsing
    case networking
}

final class DictionaryClient {
    static func entries(
        for word: String,
        completion: @escaping (Result<[Entry], DictionaryClientError>) -> Void
    ) -> URLSessionTask {
        let requestUrl = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)")!
        let dataTask = URLSession.shared.dataTask(with: requestUrl) { data, response, error in
            guard
                error == nil,
                let data = data
            else {
                completion(.failure(DictionaryClientError.networking))
                return
            }
            guard let definition = try? JSONDecoder().decode([Entry].self, from: data) else {
                completion(.failure(DictionaryClientError.parsing))
                return
            }
            completion(.success(definition))
        }
        dataTask.resume()
        return dataTask
    }

    struct Entry: Codable, Equatable {
        let word: String
        let meanings: [Meaning]

        struct Meaning: Codable, Equatable {
            let partOfSpeech: String
            let definitions: [Definition]

            struct Definition: Codable, Equatable {
                let definition: String
            }
        }
    }
}
