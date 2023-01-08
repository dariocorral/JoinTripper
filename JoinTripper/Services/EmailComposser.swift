//
//  EmailComposser.swift
//  JoinTripper
//
//  Created by Dario Corral on 30/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation
import MessageUI

class EmailComposer: NSObject, MFMailComposeViewControllerDelegate {
    
    func canSendEmail() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    
    func configuredMailComposeViewController(email: String, body: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setSubject("JoinTripper Contact Request")
        mailComposerVC.setToRecipients([email])
        mailComposerVC.setMessageBody(body, isHTML: true)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
