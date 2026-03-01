// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WordsApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "WordsApp", targets: ["WordsApp"])
    ],
    targets: [
        .executableTarget(
            name: "WordsApp",
            dependencies: [],
            path: ".",
            sources: [
                "WordsApp.swift",
                "Models/Word.swift", 
                "Views/WordDetailView.swift",
                "Services/MagicSuggestService.swift"
            ]
        )
    ]
)