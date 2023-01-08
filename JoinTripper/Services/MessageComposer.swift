//
//  MessageComposer.swift
//  JoinTripper
//
//  Created by Dario Corral on 30/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation
import MessageUI

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    //Delegate callback - dismiss viewcontroller when user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //A wrapper function to indicate whether or not the user can send a iMessage
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    //Configure and returns MFComposeViewController instance
    func configureMessageComposeViewController(email: String, body: String) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = [email]
        messageComposeVC.body = body
        
        return messageComposeVC
    }
}

