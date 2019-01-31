//
//  ExtensionVar.swift
//  Outletgen
//
//  Created by Kacper Dziubek on 31/01/2019.
//  Copyright © 2019 SPAR. All rights reserved.
//

import Foundation

struct ExtensionVar {
    var restorationID: String
    var className: String
    
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
