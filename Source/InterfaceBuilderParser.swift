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
    
    func parseConstraint(_ element: XMLElement) -> ConstraintOutlet? {
        guard let identifier = element.attribute(by: "identifier")?.text else { return nil }
        let constraintClass = element.attribute(by: "customClass")?.text ?? "NSLayoutConstraint"
        return ConstraintOutlet(constraintID: identifier, className: constraintClass)
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
                var className = "UI" + child.element!.name.capitalizingFirstLetter()
                
                if let customClass = child.element!.attribute(by: "customClass") {
                    className = customClass.text
                    modules.insert(child.element!.attribute(by: "customModule")!.text)
                }
                
                let view = UIViewOutlet(
                    restorationID: restId,
                    className: className
                )
                
                saveOutlet(extensionName: currentDestinationExtension, outlet: view)
                
                allRestorationIDs.insert(restId)
            }
            
            // Reading constraints
            if child.element!.name == "constraint" {
                let constraint = parseConstraint(child.element!)
                saveOutlet(extensionName: currentDestinationExtension, outlet: constraint)
            }
            
            readChildrenRecursivelyIn(xml: child, destinationExtension: currentDestinationExtension)
        }
    }

}
