//
//  TJAuthErrors.swift
//  BioAuth
//
//  Created by Tejas Ardeshna on 03/11/17.
//  Copyright © 2017 Tejas Ardeshna.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import LocalAuthentication

// Authentication Errors
public enum TJAuthErrors  {
    
    case appCancel, failed, userCancel, userFallback, systemCancel, passcodeNotSet, biometryNotEnrolled, biometryLockedout, invalidContext , biometryNotAvailable,other
    
    //Solution for "TJAuthErrors has no initializers"
    init?(error: LAError)  {
        switch Int32(error.errorCode) {
            
        case kLAErrorAuthenticationFailed:self = .failed
        case kLAErrorUserCancel:self = .userCancel
        case kLAErrorUserFallback:self = .userFallback
        case kLAErrorSystemCancel: self = .systemCancel
        case kLAErrorPasscodeNotSet:self = .passcodeNotSet
        case kLAErrorBiometryNotEnrolled:self = .biometryNotEnrolled
        case kLAErrorBiometryLockout:self = .biometryLockedout
        case kLAErrorAppCancel:self = .appCancel
        case kLAErrorInvalidContext: self = .invalidContext
        case kLAErrorBiometryNotAvailable: self = .biometryNotAvailable
        default: self = .other
        }
    }
    
    // get error message based on type
    public func getMessage() -> String {
        switch self {
        case .appCancel:
            return "Authentication was cancelled by application."
        case .failed:
            return "The user failed to provide valid credentials."
        case .invalidContext:
            return "The context is invalid."
        case .userFallback:
            return "The user chose to use the fallback."
        case .userCancel:
            return "The user did cance."
        case .passcodeNotSet:
            return "Passcode is not set on the device."
        case .systemCancel:
            return "Authentication was cancelled by the system."
        case .biometryNotEnrolled:
            return "Biometric is not enrolled on the device."
        case .biometryLockedout:
            return "Too many failed attempts."
        case .biometryNotAvailable:
            return "Biometric is not available on the device."
        case .other:
            return "Did not find error code on LAError object."
        }
    }
}


