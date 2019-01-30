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
    for folder in homeFolder.subfolders {
        if folder.extension == "xcodeproj" {
            return folder.nameExcludingExtension
        }
    }
    
    return nil
}
