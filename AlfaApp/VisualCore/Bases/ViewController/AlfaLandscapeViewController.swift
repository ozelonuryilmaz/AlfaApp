//
//  AlfaLandscapeViewController.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import UIKit

class AlfaLandscapeViewController<RootView: BaseRootView>: AlfaBaseViewController<RootView> {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
}
