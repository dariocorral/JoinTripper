//
//  BrowserViewController.swift
//  JoinTripper
//
//  Created by Dario Corral on 09/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import AviasalesSDK
import WebBrowser

class BrowserViewController: WebBrowserViewController {
    private let presenter: BrowserViewPresenter
    
    @objc required init(presenter: BrowserViewPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.handleLoad(viewController: self)
    }

}
