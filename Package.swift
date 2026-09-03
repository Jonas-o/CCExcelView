// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "CCExcelView",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "CCExcelView",
            targets: ["CCExcelView"]
        )
    ],
    targets: [
        .target(
            name: "CCExcelView",
            path: "CCExcelView",
            sources: ["CCViews"],
            resources: [
                .copy("CCResources/CCExcelResources.bundle")
            ],
            publicHeadersPath: "CCViews",
            linkerSettings: [
                .linkedFramework("UIKit")
            ]
        )
    ]
)
