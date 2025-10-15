//
//  WindowHelper.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import UIKit

public class WindowHelper {
    
    private init() { }
    
    public static func getWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?.windows
            .filter({ $0.isKeyWindow }).first
    }
    
    static var safeAreaTotalMargins: CGFloat {
        return topSafeAreaInset + bottomSafeAreaInset
    }
    
    static var topSafeAreaInset: CGFloat {
        return WindowHelper.getWindow()?.safeAreaInsets.top ?? 0
    }
    
    static var leftSafeAreaInset: CGFloat {
        return WindowHelper.getWindow()?.safeAreaInsets.left ?? 0
    }
    
    static var bottomSafeAreaInset: CGFloat {
        return WindowHelper.getWindow()?.safeAreaInsets.bottom ?? 0
    }
    
    static var rightSafeAreaInset: CGFloat {
        return WindowHelper.getWindow()?.safeAreaInsets.right ?? 0
    }
    
    static var hasNotch: Bool {
        return WindowHelper.bottomSafeAreaInset > 0
    }
}
