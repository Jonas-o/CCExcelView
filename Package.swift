// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "CCExcelView",
    platforms: [
        .iOS(.v12)
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
            publicHeadersPath: "include",
            cSettings: [
                // 让 .m 内的 #import "Xxx.h" 与 <CCExcelView/Xxx.h> 都能解析
                .headerSearchPath("include"),
                .headerSearchPath("include/CCExcelView")
            ],
            linkerSettings: [
                .linkedFramework("UIKit")
            ]
        )
    ]
)
