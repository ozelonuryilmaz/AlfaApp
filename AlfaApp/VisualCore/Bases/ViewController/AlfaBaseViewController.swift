//
//  AlfaBaseViewController.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 15.10.2025.
//

import UIKit
import Combine

class AlfaBaseViewController<RootView: BaseRootView>: UIViewController {
    
    let rootView: RootView = RootView()
    
    var baseBackgroundColor: UIColor {
        return Asset.viewBackground.color
    }
    
    var navigationTitle: String? {
        return nil
    }
    
    var cancelBag = Set<AnyCancellable>()
    
    private var nativeProgressView: NativeProgressView?
    
    // Sayfa kapanmalarını alt sayfaya bildirmek için kullanılıyor
    public var willDismissCallback: DefaultDismissCallback? = nil
    public var didDismissCallback: DefaultDismissCallback? = nil
    
    deinit {
        print("killed: \(type(of: self))")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navTitle = navigationTitle {
            navigationItem.title = navTitle
        } else {
            navigationItem.titleView = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.willDismissCallback?()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.didDismissCallback?()
    }

    internal func initDidLoad() {
        self.view.backgroundColor = baseBackgroundColor
        self.nativeProgressView = NativeProgressView()
        self.setupRootView()
        self.setupView()
        self.initialComponents()
    }
    
    // for all sub class
    func setupView() { }
    
    // for all sub class
    func initialComponents() { }
    
    // Layout Injection Point (don't change superview default value !!!)
    func setLayoutStyle() -> (top: EdgeLayoutStyle, leading: EdgeLayoutStyle, bottom: EdgeLayoutStyle, trailing: EdgeLayoutStyle) {
        return (.superview, .superview, .superview, .superview)
    }
}

// MARK: Native Progress View
extension AlfaBaseViewController {
    
    func playNativeLoading(isLoading: Bool) {
        if isLoading {
            self.playNativeLoading()
        } else {
            self.stopNativeLoading()
        }
    }
    
    func playNativeLoading() {
        nativeProgressView?.playAnimation()
    }
    
    func stopNativeLoading() {
        nativeProgressView?.stopAnimation()
    }
}

// MARK: Handle Error
extension AlfaBaseViewController {
    /*
    func observeErrorState(errorState: ErrorStateSubject,
                           errorHandle: RestApiErrorHandle) {
        /*errorState.sink(receiveValue: { [weak self] errorType in
         self?.handleApiError(errorType: errorType,
         errorHandler: errorHandle)
         }).store(in: &cancelBag)*/
    }
    
    private func handleApiError(errorType: NetworkingError?,
                                errorHandler: RestApiErrorHandle) {
        
        /*switch errorType {
         case .COMMON_ERROR(_),
         .UNDEFINED_RESPONSE_TYPE:
         
         errorHandler.handleCommonError(title: nil, errorMessage: errorType?.description ?? "Beklenmedik bir hata oluştu")
         case .ERROR_MESSAGE(let title, let msg):
         errorHandler.handleCommonError(title: title, errorMessage: msg)
         
         case .none:
         break
         }*/
    }*/
}

// MARK: Private Setup Background View
private extension AlfaBaseViewController {
    
    func setupRootView() {
        let layoutStyles = setLayoutStyle()
        view.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: anchor(for: layoutStyles.top, edge: .top)),
            rootView.bottomAnchor.constraint(equalTo: anchor(for: layoutStyles.bottom, edge: .bottom)),
            rootView.leadingAnchor.constraint(equalTo: anchor(for: layoutStyles.leading, edge: .leading)),
            rootView.trailingAnchor.constraint(equalTo: anchor(for: layoutStyles.trailing, edge: .trailing))
        ])
    }
    
    func anchor(for style: EdgeLayoutStyle, edge: LayoutEdge) -> NSLayoutYAxisAnchor {
        switch (style, edge) {
        case (.safeArea, .top): return view.safeAreaLayoutGuide.topAnchor
        case (.safeArea, .bottom): return view.safeAreaLayoutGuide.bottomAnchor
        case (.superview, .top): return view.topAnchor
        case (.superview, .bottom): return view.bottomAnchor
        default:
            fatalError("Invalid layout combination for vertical anchor: \(edge)")
        }
    }
    
    func anchor(for style: EdgeLayoutStyle, edge: LayoutEdge) -> NSLayoutXAxisAnchor {
        switch (style, edge) {
        case (.safeArea, .leading): return view.safeAreaLayoutGuide.leadingAnchor
        case (.safeArea, .trailing): return view.safeAreaLayoutGuide.trailingAnchor
        case (.superview, .leading): return view.leadingAnchor
        case (.superview, .trailing): return view.trailingAnchor
        default:
            fatalError("Invalid layout combination for horizontal anchor: \(edge)")
        }
    }
    
    enum LayoutEdge {
        case top, bottom, leading, trailing
    }
}

enum EdgeLayoutStyle {
    case superview
    case safeArea
}
