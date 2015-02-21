//
//  PlotViewController.swift
//  Calculator
//
//  Created by Luca Pesavento on 20/02/2015.
//  Copyright (c) 2015 Luca Pesavento. All rights reserved.
//

import Foundation
import UIKit

class PlotViewController: UIViewController {
    
    @IBOutlet weak var formulaLabel: UILabel!
    
    var formula: String! {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        formulaLabel?.text = self.formula ?? " "
    }
    
}