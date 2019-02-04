//
//  XMLExtensions.swift
//  Outletgen
//
//  Created by Kacper Dziubek on 02/02/2019.
//  Copyright © 2019 Outletgen. All rights reserved.
//

import Foundation

extension XMLElement {
    var outletID : String? {
        get {
            let attributes = self.xmlChildren.filter { $0.name == "userDefinedRuntimeAttributes" }
            guard let runtimeAttrs = attributes.first else { return nil }
            let outlets = runtimeAttrs.xmlChildren.filter {
                return $0.allAttributes["keyPath"]?.text == "outletIdentifier"
            }
            return outlets.first?.attribute(by: "value")?.text
        }
    }
}
