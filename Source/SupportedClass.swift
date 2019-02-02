//
//  SupportedClasses.swift
//  Outletgen
//
//  Created by Kacper Dziubek on 02/02/2019.
//  Copyright © 2019 Outletgen. All rights reserved.
//

import Foundation


let supportedClasses = [
    SupportedClass(name: "UIBarItem"),
    SupportedClass(name: "UIView"),
    SupportedClass(name: "NSLayoutConstraint")
]

func getSupportedClassesCode() -> String {
    var supportedClassesCode = ""
    
    for supportedClass in supportedClasses {
        supportedClassesCode += supportedClass.code
    }
    
    return supportedClassesCode
}


struct SupportedClass {
    
    var name: String
    
    var code: String {
        get {
            return
"""
            
extension \(name) {
    @IBInspectable var outletIdentifier: String? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.outletIdentifier, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.outletIdentifier) as? String else { return nil }
            return value
        }
    }
}
            
"""
        }
    }
}


