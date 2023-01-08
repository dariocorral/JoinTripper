//
//  Array+Unique.swift
//  JoinTripper
//
//  Created by Dario Corral on 24/11/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    func removeDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}
