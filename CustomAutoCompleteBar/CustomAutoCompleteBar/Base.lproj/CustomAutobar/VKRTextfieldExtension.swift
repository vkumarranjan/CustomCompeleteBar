//
//  VKRTextfieldExtension.swift
//  CustomAutoCompleteBar
//
//  Created by Vinay on 12/06/17.
//  Copyright © 2017 Vinay Nation. All rights reserved.
//

import Foundation
import UIKit


extension UITextField {
    
    func setAutocompleteWith(_ dataSource: AutoCompleteDataSource, delegate: AutoCompleteDelegate, customize customizeView: @escaping (_ inputView: AutoCompleteInputView) -> Void) {
        
        let autocompleteBarView = AutoCompleteInputView()
        self.inputAccessoryView = autocompleteBarView
        // self.delegate = autocompleteBarView
        self.autocorrectionType = .no
        // pass the view to the caller to customize it
        customizeView(autocompleteBarView)
        
        
        // set the protocols
        autocompleteBarView.textField = self
        autocompleteBarView.delegate = delegate
        autocompleteBarView.dataSource = dataSource
        
        // init state is not visible
        self.addTarget(autocompleteBarView, action: #selector(AutoCompleteInputView.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        
        autocompleteBarView.show(false, withAnimation: false)
        
    }
    
    
}
