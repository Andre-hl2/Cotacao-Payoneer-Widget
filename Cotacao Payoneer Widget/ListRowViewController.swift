//
//  ListRowViewController.swift
//  Cotacao Payoneer Widget
//
//  Created by Andre Ferreira dos Santos on 13/06/17.
//  Copyright © 2017 SukafuSoftworks. All rights reserved.
//

import Cocoa

class ListRowViewController: NSViewController {

    @IBOutlet weak var FieldName: NSTextField!
    @IBOutlet weak var FieldValue: NSTextField!
    var quotation : Quotation!
    
    override var nibName: String? {
        return "ListRowViewController"
    }

    public func setFields(quotation : Quotation) {
        self.quotation = quotation
    }
    
    override func loadView() {
        super.loadView()
        // Insert code here to customize the view
    }
    
    override func viewWillAppear() {
        FieldName.stringValue = quotation.name!
        FieldValue.stringValue = quotation.value!
    }
}
