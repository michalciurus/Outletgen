//
//  InterfaceBuilderParser.swift
//  Outletgen
//
//  Created by Michal Ciurus on 02/02/2019.
//

import Foundation

class InterfaceBuilderParser {
    
    // Modules to import
    var modules: Set<String> = []
    // Code for view controller extensions and their outlet views
    typealias OutletsDict = [String : Outlet]
    // Generated outlet code
    var viewControllersExtensionCode: [String : OutletsDict] = [ : ]
    var allRestorationIDs: Set<String> = []
    
    
    func parseXib(file: File) {
        let fileString = try! file.readAsString()
        let xml = SWXMLHash.parse(fileString)
        
        readChildrenRecursivelyIn(xml: xml, destinationExtension: nil)
    }
    
    func saveOutlet(extensionName: String?, outlet: Outlet?) {
        guard let vc = extensionName else { return }
        guard let outlet = outlet else { return }
        
        if viewControllersExtensionCode[vc] == nil {
            viewControllersExtensionCode[vc] = OutletsDict()
        }
        
        viewControllersExtensionCode[vc]?[outlet.id] = outlet
    }
    
    func readChildrenRecursivelyIn(xml: XMLIndexer, destinationExtension: String?) {
        // This is the Swift extension where the found views will be generated in
        var currentDestinationExtension = destinationExtension
        
        for child in xml.children {
            // Reading ViewControllers destinations
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
            
            // Reading table view and collection view cells and subviews destinations
            let collectionViewElements = ["tableViewCell", "collectionViewCell", "collectionReusableView"]
            if collectionViewElements.contains(child.element!.name)  {
                currentDestinationExtension = child.element!.attribute(by: "customClass")?.text
            }
            
            // Reading the xib owners destinations
            if child.element!.attribute(by: "userLabel")?.text == "File's Owner" {
                currentDestinationExtension = child.element!.attribute(by: "customClass")?.text
            }
            
            if let restId = child.element?.attribute(by: "restorationIdentifier")?.text {
                let className = getClassName(child.element!)
                
                let view = UIViewOutlet(
                    restorationID: restId,
                    className: className
                )
                
                saveOutlet(extensionName: currentDestinationExtension, outlet: view)
                
                allRestorationIDs.insert(restId)
            }
            
            if let outletID = child.element?.outletID {
                print ("\(child.element!.name) \(outletID)")
                let className = getClassName(child.element!)
                
                let view = UIViewOutlet(
                    restorationID: outletID,
                    className: className
                )
                
                saveOutlet(extensionName: currentDestinationExtension, outlet: view)
                
                allRestorationIDs.insert(outletID)
            }
            
            readChildrenRecursivelyIn(xml: child, destinationExtension: currentDestinationExtension)
        }
    }
    
    private func getClassName(_ element: XMLElement) -> String {
        // check if element has custom class
        if let customClass = element.attribute(by: "customClass") {
            modules.insert(element.attribute(by: "customModule")!.text)
            return customClass.text
        }
        
        return getUIKitClassName(element)
    }
    
    private func getUIKitClassName(_ element: XMLElement) -> String {
        // Map containig classes names used when class name defined in xml
        // does not match UIKit clas name by just appending UI prefix
        let classesMap = [
            "constraint" : "NSLayoutConstraint",
            "containerView": "UIView"
        ]
        
        let className = element.name
        
        return classesMap[className] ?? "UI" + className.capitalizingFirstLetter()
        
    }

}
