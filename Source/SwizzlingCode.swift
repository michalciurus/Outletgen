//
//  SwizzlingCode.swift
//  Outletgen
//
//  Created by Michal Ciurus on 30/01/2019.

import Foundation

let logicCode = """

extension String {
    var address: UnsafeRawPointer {
        return UnsafeRawPointer(bitPattern: abs(self.hashValue))!
    }
}

public protocol SwizzlingInjection: class {
    static func inject()
    
    func findAllViewsWithOutlets(view: UIView)
}

extension SwizzlingInjection {
    public func findAllViewsWithOutlets(view: UIView) {

        if view.restorationIdentifier != nil {
            AllAssociatedObjectsKeys.forEach { (key) in
                if key == view.restorationIdentifier {
                    objc_setAssociatedObject(self, key.address, view, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }

        }


        if let id = view.outletIdentifier {
            AllAssociatedObjectsKeys.forEach { (key) in
                if key == id {
                    objc_setAssociatedObject(self, key.address, view, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
            }
        }

        // for UIBarItems
        if view.isKind(of: UIToolbar.self) {
            if let toolbar = view as? UIToolbar {
                findUIBarItems(items: toolbar.items)
            }
        }

        for constraint in view.constraints {
            if let id = constraint.outletIdentifier {
                AllAssociatedObjectsKeys.forEach { (key) in
                    if key == id {
                        objc_setAssociatedObject(self, key.address, constraint, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    }
                }
            }
        }
        for subview in view.subviews {
            findAllViewsWithOutlets(view: subview)
        }
    }
    
    public func findUIBarItems(items: [UIBarItem]?) {
        guard let items = items else { return }
        for item in items {
            if let id = item.outletIdentifier {
                AllAssociatedObjectsKeys.forEach { (key) in
                    if key == id {
                        objc_setAssociatedObject(self, key.address, item, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    }
                }
            }
        }
    }
}

class SwizzlingHelper {
    
    private static let doOnce: Any? = {
        UIViewController.inject()
        UIView.inject()
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

extension UIView: SwizzlingInjection {
    public static func inject() {
        let originalSelector = #selector(UIView.awakeFromNib)
        let swizzledSelector = #selector(UIView.viewAwoken)
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)!
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)!
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    }
    
    @objc func viewAwoken() {
        self.viewAwoken()
        findAllViewsWithOutlets(view: self)
    }
}

extension UIViewController: SwizzlingInjection {
    
    public static func inject() {
        let originalSelector = #selector(UIViewController.loadView)
        let swizzledSelector = #selector(UIViewController.viewLoaded)
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)!
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)!
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
    
    @objc func viewLoaded() {
        self.viewLoaded()
        
        findAllViewsWithOutlets(view: view)
        findUIBarItems(items: navigationItem.leftBarButtonItems)
        findUIBarItems(items: navigationItem.rightBarButtonItems)
    }
}


struct AssociatedKeys {
    static var outletIdentifier: UInt8 = 0
}

"""
