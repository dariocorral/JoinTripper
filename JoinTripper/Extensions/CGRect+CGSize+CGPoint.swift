//
//  CGRect+CGSize+CGPoint.swift
//  JoinTripper
//
//  Created by Dario Corral on 11/11/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit

extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}
