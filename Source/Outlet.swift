//
//  ExtensionVar.swift
//  Outletgen
//
//  Created by Kacper Dziubek on 31/01/2019.
//

import Foundation


protocol Outlet {
    var id: String { get }
    var className: String { get set }
    var code: String { get }
}

struct UIViewOutlet : Outlet  {
    var restorationID: String
    var className: String
    
    var id: String {
        get {
            return restorationID
        }
    }
    
    var code : String {
        get {
            var code = ""
            code +=  "\n    var \(restorationID): \(className)! {"
            code +=  "\n        get { return objc_getAssociatedObject(self, \"\(restorationID)\".address) as? \(className) }"
            code +=  "\n        set { }"
            code +=  "\n    }"
            return code
        }
    }
}
