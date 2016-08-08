//
//  URL.swift
//  Strip
//
//  Created by Fabian Canas on 8/1/16.
//  Copyright © 2016 Fabian Canas. All rights reserved.
//

import Foundation

extension NSString {
    var fullRange :NSRange {
        get {
            return NSRange(location: 0, length: self.length)
        }
    }
}

extension String {
    func deepestDirectoryPath() -> String {
        if self.hasSuffix("/") {
            return self
        }
        guard let lastSlashIndex = self.range(of: "/", options: .backwards)?.lowerBound else {
            return "/"
        }
        
        return self.substring(to: self.index(after: lastSlashIndex))
    }
}

extension URL {
    enum HLSResource {
        case Playlist
        case Media
        
        init(string: String) {
            
            enum PlaylistTypes : String {
                case m3u8, m3u
            }
            
            self = PlaylistTypes(rawValue: string.lowercased()) == nil ? .Media : .Playlist
        }
    }
    
    var type :HLSResource? {
        return fileExtension.flatMap { HLSResource(string: $0) }
    }
    
    func directoryURL() -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.path = path.deepestDirectoryPath() ?? "/"
        return components.url!
    }
    
    private var fileExtension :String? {
        get {
            return self.path.components(separatedBy: ".").last
        }
    }
}
