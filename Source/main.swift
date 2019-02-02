//
//  main.swift
//  Outletgen
//
//  Created by Michal Ciurus on 28/01/2019.

import Foundation

func parseRecursivelyFilesIn(folder: Folder, with parser: InterfaceBuilderParser) {
    
    for subfolder in folder.subfolders {
        parseRecursivelyFilesIn(folder: subfolder, with: parser)
    }
    
    for file in folder.files {
        if file.extension == "xib" || file.extension == "storyboard" {
            parser.parseXib(file: file)
        }
    }
}

//MARK: SETTING UP, FINDING FILES, PARSING FILES

let homeFolder = try! Folder(path: "")
let file = try homeFolder.createFile(named: "Outletgen.swift")

let parser = InterfaceBuilderParser()

parseRecursivelyFilesIn(folder: homeFolder, with: parser )


//MARK: GENERATING CODE

var generatedCode = ""
generatedCode += "//Auto Generated Code \n\n"
generatedCode += "import UIKit"


//MARK: IMPORT GENERATION

for module in parser.modules {
    if module != getCurrentModuleName() {
        generatedCode += "\nimport \(module)"
    }
}

//MARK: GENERATING EXTENSION CODE

for vcKey in parser.viewControllersExtensionCode.keys {
    generatedCode += "\n \n"
    generatedCode += "\nextension \(vcKey) {"
    for extensionVar in parser.viewControllersExtensionCode[vcKey]!.keys {
        generatedCode += parser.viewControllersExtensionCode[vcKey]![extensionVar]!.code
    }
    generatedCode += "\n }"
}

generatedCode += "\n \n"

//MARK: GENERATING KEY ARRAY

generatedCode += "\nlet AllAssociatedObjectsKeys = "
generatedCode += "["

var keysArrayCode: String = ""

for restId in parser.allRestorationIDs {
    if keysArrayCode != "" {
        keysArrayCode = keysArrayCode + ", "
    }
    
    keysArrayCode = keysArrayCode + "\"\(restId)\""
}

generatedCode += keysArrayCode
generatedCode += "]"

//MARK: ADDING THE CODE FOR SWIZZLING

generatedCode += "\n\n//Swizzling Code \n\n"
generatedCode += logicCode

try! file.append(string: generatedCode)
