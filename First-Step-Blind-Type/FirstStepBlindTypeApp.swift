import SwiftUI

@main
struct FirstStepBlindTypeApp: App {
    @State private var typeLinkStatus: Bool? = nil

    private let typeSourceLink = "https://firststepblindtype.org/click.php"
    private let typeCheckDomain = "freeprivacypolicy.com"

    var body: some Scene {
        WindowGroup {
            Group {
                if let status = typeLinkStatus {
                    if status {
                        TypeWebPanel(urlString: typeSourceLink)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        ContentView()
                    }
                } else {
                    TypeLoadingScreen()
                        .onAppear { verifyTypeLink() }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private func verifyTypeLink() {
        guard let url = URL(string: typeSourceLink) else {
            typeLinkStatus = false
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        let resolver = TypeRedirectResolver(checkDomain: typeCheckDomain)
        let session = URLSession(configuration: .default, delegate: resolver, delegateQueue: nil)

        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if resolver.foundCheckDomain {
                    typeLinkStatus = false
                    return
                }
                if let finalURL = resolver.resolvedURL?.absoluteString,
                   finalURL.contains(self.typeCheckDomain) {
                    typeLinkStatus = false
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   let responseURL = httpResponse.url?.absoluteString,
                   responseURL.contains(self.typeCheckDomain) {
                    typeLinkStatus = false
                    return
                }
                if error != nil {
                    typeLinkStatus = false
                    return
                }
                typeLinkStatus = true
            }
        }.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if typeLinkStatus == nil { typeLinkStatus = false }
        }
    }
}
