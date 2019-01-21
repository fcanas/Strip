//
//  main.swift
//  Strip
//
//  Created by Fabian Canas on 8/7/16.
//  Copyright © 2016 Fabian Canas. All rights reserved.
//

import Foundation
import scrapeLib
import FFCLog

/// Argument Parsing

let processInfo = ProcessInfo()

var args: [String] = Array(processInfo.arguments[1..<processInfo.arguments.count])

enum Option: String, CaseIterable {
    case playlistOnly = "-p"
    case verbose = "-v"
}

extension Option {
    var usageDescription: String {
        switch self {
        case .playlistOnly:
            return "download only playlist files"
        case .verbose:
            return "verbose output"
        }
    }
}

func printUsage() {
    print("usage: scrape \(Option.allCases.reduce("", { $0 + "[\($1.rawValue)] " }))input_url output_url")
    print("  input_url     a remote URL to an m3u8 HLS playlist")
    print("  output_url    a local path where the HLS stream should be saved")
    Option.allCases.forEach { (opt) in
        print("  \(opt.rawValue)            \(opt.usageDescription)")
    }
}

guard args.count >= 2 else {
    print("At least 2 arguments needed.")
    printUsage()
    exit(EXIT_FAILURE)
}

guard let destinationURL = URL(localOrRemoteString:args.popLast()!) else {
    print("Destination path appears invalid")
    printUsage()
    exit(EXIT_FAILURE)
}

guard let sourceURL = URL(localOrRemoteString:args.popLast()!) else {
    print("Source URL appears invalid")
    printUsage()
    exit(EXIT_FAILURE)
}

let downloader = Downloader(destination: destinationURL)

while let arg = args.popLast() {
    guard let option = Option(rawValue: arg) else {
        print("Unrecognized option: \(arg)")
        printUsage()
        exit(EXIT_FAILURE)
    }
    switch option {
    case .playlistOnly:
        downloader.urlFilter = { url in
            url.fileExtension.hasPrefix("m3u")
        }
    case .verbose:
        Level.global = .all
    }
}

downloader.downloadHLSResource(sourceURL)

downloader.group.wait()

