//
//  UIGestureRecognizer+Closures.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import UIKit

private var HandlerKey: UInt8 = 0
internal let ClosureHandlerSelector = Selector(("handle"))

public extension UITapGestureRecognizer {
    
    convenience init(taps: Int = 1, touches: Int = 1, handler: @escaping (UITapGestureRecognizer) -> Void) {
        let handler = ClosureHandler<UITapGestureRecognizer>(handler: handler)
        self.init(target: handler, action: ClosureHandlerSelector)
        setHandler(self, handler: handler)
        numberOfTapsRequired = taps
        numberOfTouchesRequired = touches
    }
}

internal extension UIGestureRecognizer {
    
    func setHandler<T: UIGestureRecognizer>(_ instance: T, handler: ClosureHandler<T>) {
        objc_setAssociatedObject(self, &HandlerKey, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        handler.control = instance
    }
    
    func handler<T>() -> ClosureHandler<T> {
        return objc_getAssociatedObject(self, &HandlerKey) as! ClosureHandler
    }
}

internal class ClosureHandler<T: AnyObject>: NSObject {
    
    internal var handler: ((T) -> Void)?
    internal weak var control: T?
    
    internal init(handler: @escaping (T) -> Void, control: T? = nil) {
        self.handler = handler
        self.control = control
    }
    
    @objc func handle() {
        if let control = self.control {
            handler?(control)
        }
    }
}
