//
//  HistoryLabel.swift
//  Calculator
//
//  Created by Luca Pesavento on 13/02/2015.
//  Copyright (c) 2015 Luca Pesavento. All rights reserved.
//

import Foundation
import UIkit

@IBDesignable
class HistoryLabel: UILabel {

    var maxRows: Int = 1 { didSet { self.setNeedsDisplay() }}

}