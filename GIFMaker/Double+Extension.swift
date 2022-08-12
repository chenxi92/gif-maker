//
//  Double+Extension.swift
//  GIFMaker
//
//  Created by peak on 2022/8/12.
//

import Foundation

extension Double {
    func toString(_ length: Int = 1) -> String {
        String(format: "%.\(length)f", self)
    }
}
