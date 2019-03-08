//
//  Helpers.swift
//  Outletgen
//
//  Created by Michal Ciurus on 30/01/2019.

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

// This is very naive for now, just reading project name and assuming the module name will be the same
// TODO: Read project file and find module name
func getCurrentModuleName() -> String? {
    if let module = CommandLine.arguments.namedArguments["module"] {
        return module
    }
    
    for folder in homeFolder.subfolders {
        if folder.extension == "xcodeproj" {
            return folder.nameExcludingExtension
        }
    }
    
    return nil
}


extension Array where Element : StringProtocol {
    var namedArguments : [String: String] {
        get {
            var named = [String: String]()
            for (index, arg) in self.enumerated() {
                let nindex = index + 1
                let argValue = indices.contains(nindex) ? self[nindex] : nil
                if arg.starts(with: "--"), let argValue = argValue  {
                    named[String(arg.dropFirst(2))] = String(argValue)
                }
            }
            return named
        }
    }
}
