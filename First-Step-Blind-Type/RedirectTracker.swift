import Foundation

class TypeRedirectResolver: NSObject, URLSessionTaskDelegate {
    private let urlString: String
    private let timeoutSeconds: Double
    private let completion: (Result<String, Error>) -> Void
    private var hasCompleted = false

    init(urlString: String, timeoutSeconds: Double, completion: @escaping (Result<String, Error>) -> Void) {
        self.urlString = urlString
        self.timeoutSeconds = timeoutSeconds
        self.completion = completion
        super.init()
    }

    func start() {
        guard let url = URL(string: urlString) else {
            finish(.failure(NSError(domain: "TypeRedirectResolver", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutSeconds
        config.timeoutIntervalForResource = timeoutSeconds

        let session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        let task = session.dataTask(with: url) { [weak self] _, response, error in
            guard let self = self else { return }
            if let error = error {
                self.finish(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse, let finalURL = httpResponse.url?.absoluteString {
                self.finish(.success(finalURL))
            } else {
                self.finish(.failure(NSError(domain: "TypeRedirectResolver", code: -2, userInfo: [NSLocalizedDescriptionKey: "No response"])))
            }
        }
        task.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutSeconds) { [weak self] in
            self?.finish(.failure(NSError(domain: "TypeRedirectResolver", code: -3, userInfo: [NSLocalizedDescriptionKey: "Timeout"])))
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }

    private func finish(_ result: Result<String, Error>) {
        guard !hasCompleted else { return }
        hasCompleted = true
        completion(result)
    }
}
