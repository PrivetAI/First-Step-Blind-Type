import SwiftUI

@main
struct BlindTypeTrainerApp: App {
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
                        TypeWebPanel(urlString: "https://example.com")
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
        let resolver = TypeRedirectResolver(urlString: "https://example.com", timeoutSeconds: 5) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let finalURL):
                    typeLinkStatus = finalURL.contains("example")
                case .failure:
                    typeLinkStatus = true
                }
            }
        }
        resolver.start()
    }
}
