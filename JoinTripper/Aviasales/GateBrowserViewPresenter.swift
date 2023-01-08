//
//  GateBrowserViewPresenter.swift
//  JoinTripper
//
//  Created by Dario Corral on 08/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import AviasalesSDK
import WebBrowser


@objcMembers
class GateBrowserViewPresenter: NSObject {
    
    fileprivate weak var viewController: WebBrowserViewController?
    fileprivate let proposal: JRSDKProposal
    fileprivate let purchasePerformer: AviasalesSDKPurchasePerformer
    fileprivate var request: URLRequest?
    
    init(ticketProposal: JRSDKProposal, searchID: String) {
        proposal = ticketProposal
        purchasePerformer = AviasalesSDKPurchasePerformer(proposal: ticketProposal, searchId: searchID)
        super.init()
    }
}

extension GateBrowserViewPresenter: AviasalesSDKPurchasePerformerDelegate {
    
    public func purchasePerformer(_ performer: AviasalesSDKPurchasePerformer!, didFinishWith URLRequest: URLRequest!, clickID: String!) {
        viewController?.loadRequest(URLRequest)
        self.request = URLRequest
        print(URLRequest.url?.absoluteString ?? "Not URL Request")
        
    }
    
    func purchasePerformer(_ performer: AviasalesSDKPurchasePerformer!, didFailWithError error: Error!) {
        if error != nil {
            print("Error URL Request")
            viewController?.showAlert(title: "Error", description: "Server Error. Try later")
            viewController?.dismiss(animated: true, completion: nil)
        }
    }
}

@objc protocol BrowserViewPresenter {
    func handleLoad(viewController: WebBrowserViewController)
}

extension GateBrowserViewPresenter: BrowserViewPresenter, WebBrowserDelegate {
    
    func handleLoad(viewController: WebBrowserViewController) {
        self.viewController = viewController
        viewController.delegate = self
        viewController.language = .english
        viewController.tintColor = ColorHex.hexStringToUIColor(hex: "#526CA0")
        viewController.barTintColor = ColorHex.hexStringToUIColor(hex: "#F2B2AF")
        viewController.isToolbarHidden = false
        viewController.isShowActionBarButton = true
        viewController.toolbarItemSpace = 50
        viewController.isShowURLInNavigationBarWhenLoading = false
        viewController.isShowPageTitleInNavigationBar = true
        
        purchasePerformer.perform(with: self)
        
    }
}
