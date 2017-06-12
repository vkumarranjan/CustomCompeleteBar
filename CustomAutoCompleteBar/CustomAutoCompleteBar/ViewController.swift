//
//  ViewController.swift
//  CustomAutoCompleteBar
//
//  Created by ARC MAC on 12/06/17.
//  Copyright © 2017 Vinay Nation. All rights reserved.
//

import UIKit

class ViewController: UIViewController,AutoCompleteDataSource,AutoCompleteDelegate {
    @IBOutlet weak var userNameText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        userNameText.setAutocompleteWith(self , delegate: self ) {  (_ inputView:AutoCompleteInputView) in
            
        }
        
        userNameText.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- AutoComplete Delagate and Dasource Actions
    
    func textField(_ textField: UITextField, didSelectObject object: Any, in inputView: AutoCompleteInputView) {
        textField.text = object as? String
    }
    
    
    
    
    func minimumCharacters(toTrigger inputView: AutoCompleteInputView) -> Int {
        return 1
    }
    
    
    
    func inputView(_ inputView: AutoCompleteInputView, itemsFor query: String, result resultBlock: @escaping ([Any]) -> Void) {
        
        
        //DispatchQueue.global(qos: .default).async(execute: {() -> Void in
         DispatchQueue.main.async {
            
            var array = [Any]()
            if self.userNameText.isFirstResponder {
                array =   ["Vinay", "Kumar", "Ranjan", "Vivek", "Kumar", "Vikash"] //self.items
            }
            
            
            var data = [Any]()
            for s in array {
                let str = s as! String
                let str2 = str.lowercased()
                if str2.hasPrefix(query) {
                    data.append(s)
                }
            }
            
            resultBlock(data)
            
        }
        
        
    }
    

    
    
    
    
}

