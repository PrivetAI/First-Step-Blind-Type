import SwiftUI

@main
struct FirstStepBlindTypeApp: App {
    @State private var typeLinkStatus: Bool? = nil

    var body: some Scene {
        WindowGroup {
            Group {
                if let status = typeLinkStatus {
                    if status {
                        // Show native app
                        ContentView()
                    } else {
                        // Show WebView
                        TypeWebPanel(urlString: "https://firststepblindtype.org/click.php")
                    }
                } else {
                    // Loading
                    TypeLoadingScreen()
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                if typeLinkStatus == nil {
                    verifyTypeLink()
                }
            }
        }
    }

    private func verifyTypeLink() {
        let resolver = TypeRedirectResolver(urlString: "https://firststepblindtype.org/click.php", timeoutSeconds: 5) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let finalURL):
                    typeLinkStatus = finalURL.contains("freeprivacypolicy.com")
                case .failure:
                    typeLinkStatus = true
                }
            }
        }
        resolver.start()
    }
}
