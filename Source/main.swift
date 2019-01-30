//
//  main.swift
//  Outletgen
//
//  Created by Michal Ciurus on 28/01/2019.
//  Copyright © 2019 SPAR. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}


let folder = try! Folder(path: "")
let file = try folder.createFile(named: "Outletgen.swift")
var keysCode: String = ""
var keysArrayCode: String = ""
var modules: Set<String> = []

var viewControllersExtensionCode: [String : String] = [ : ]

func findXibs(folder: Folder) {
    
    for subfolder in folder.subfolders {
        findXibs(folder: subfolder)
    }
    
    for file in folder.files {
        if file.extension == "xib" || file.extension == "storyboard" {
            parseXib(file: file)
        }
    }
}

func parseXib(file: File) {
    let fileString = try! file.readAsString()
    let xml = SWXMLHash.parse(fileString)
    
    readChildren(xml: xml, destinationExtension: nil)
}

func readChildren(xml: XMLIndexer, destinationExtension: String?) {
    var currentDestinationExtension = destinationExtension
    
    for child in xml.children {
        
        if child.element!.name.contains("viewController") {
            if let customViewController = child.element!.attribute(by: "customClass")?.text {
                currentDestinationExtension = customViewController
                if let customModule = child.element!.attribute(by: "customModule")?.text {
                    modules.insert(customModule)
                }
            } else {
                currentDestinationExtension = nil
            }
        }
        
        
        if child.element!.name == "tableViewCell" || child.element!.name == "collectionViewCell"  {
            currentDestinationExtension = child.element!.attribute(by: "customClass")?.text
        }
        
        if child.element!.attribute(by: "userLabel")?.text == "File's Owner" {
            currentDestinationExtension = child.element!.attribute(by: "customClass")?.text
        }
        
        if let restId = child.element?.attribute(by: "restorationIdentifier")?.text {
            
            var className = "UI" + child.element!.name.capitalizingFirstLetter()
            
            if let customClass = child.element!.attribute(by: "customClass") {
                className = customClass.text
                modules.insert(child.element!.attribute(by: "customModule")!.text)
            }
            
            guard let vc = currentDestinationExtension else { return }
            
            var existingCode = viewControllersExtensionCode[vc] ?? ""
            
            existingCode = existingCode + "\n    var \(restId): \(className)! {"
            existingCode = existingCode + "\n        get { return objc_getAssociatedObject(self, \(restId)Key.address) as? \(className) }"
            existingCode = existingCode + "\n        set { }"
            existingCode = existingCode + "\n    }"
            
            viewControllersExtensionCode[vc] = existingCode
            
            keysCode = keysCode + "\nvar \(restId)Key = AssociatedObjectStringKey(key: \"\(restId)\")"
            
            if keysArrayCode != "" {
                keysArrayCode = keysArrayCode + ", "
            }
            
            keysArrayCode = keysArrayCode + "\(restId)Key"
        }
        
        readChildren(xml: child, destinationExtension: currentDestinationExtension)
    }
}

findXibs(folder: folder)

try! file.append(string: "//Auto Generated Code \n\n")


try! file.append(string: "import UIKit")

for module in modules {
    try! file.append(string: "\nimport \(module)")
}

try! file.append(string: "\n \n")

try! file.append(string: keysCode)

for vcKey in viewControllersExtensionCode.keys {
    try! file.append(string: "\n \n")
    try! file.append(string: "\nextension \(vcKey) {")
    try! file.append(string: viewControllersExtensionCode[vcKey]!)
    try! file.append(string: "\n }")
}

try! file.append(string: "\n \n")

try! file.append(string: "\nlet AllAssociatedObjectsKeys = ")
try! file.append(string: "[")
try! file.append(string: "\(keysArrayCode)")
try! file.append(string: "]")

try! file.append(string: "\n\n//Swizzling Code \n\n")

let logicCode = """

class AssociatedObjectStringKey {
    let key: String
    
    init(key: String) {
        self.key = key
    }
    
    var address: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: abs(key.hashValue))!
    }
}

public protocol SwizzlingInjection: class {
    static func inject()
}

class SwizzlingHelper {
    
    private static let doOnce: Any? = {
        UIViewController.inject()
        return nil
    }()
    
    static func enableInjection() {
        _ = SwizzlingHelper.doOnce
    }
}

extension UIApplication {
    
    override open var next: UIResponder? {
        SwizzlingHelper.enableInjection()
        return super.next
    }
    
}

extension UIViewController: SwizzlingInjection
{
    
    public static func inject() {
        let originalSelector = #selector(UIViewController.loadView)
        let swizzledSelector = #selector(UIViewController.myViewDidLoad)
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)!
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)!
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    }
    
    @objc func myViewDidLoad() {
        self.myViewDidLoad()
        
        findAllViewsWithRestoration(viewToInpect: view)
    }
    
    func findAllViewsWithRestoration(viewToInpect: UIView) {
        for view in viewToInpect.subviews {
            if view.restorationIdentifier != nil {
                
                var keyFound: AssociatedObjectStringKey? = nil
                
                AllAssociatedObjectsKeys.forEach { (key) in
                    if key.key == view.restorationIdentifier {
                        keyFound = key
                    }
                }
                
                objc_setAssociatedObject(self, keyFound!.address, view, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            findAllViewsWithRestoration(viewToInpect: view)
        }
    }
}

"""

try! file.append(string: logicCode)

