//
//  VKRAutoCompleteInputView.swift
//  CustomAutoCompleteBar
//
//  Created by ARC MAC on 12/06/17.
//  Copyright © 2017 Vinay Nation. All rights reserved.
//

import Foundation
import UIKit


let kDefaultHeight = 40.0
let kDefaultMargin = 5.0
let kTagRotatedView = 101.0
let kTagLabelView = 102.0

@objc protocol AutoCompleteItem : NSObjectProtocol  {
    
    // used to display text on the autoComplete bar
    func autoCompleteString() -> String
}


@objc protocol AutoCompleteDelegate: UITextFieldDelegate {
    // called when the user tap on one of the suggestions
    func textField(_ textField: UITextField, didSelectObject object: Any, in inputView:AutoCompleteInputView)
}


@objc protocol AutoCompleteDataSource : NSObjectProtocol {
    
    // number of characters required to trigger the search on possible suggestions
    func minimumCharacters(toTrigger inputView: AutoCompleteInputView) -> Int
    // use the block to return the array of items asynchronously based on the query string
    
    func inputView(_ inputView: AutoCompleteInputView, itemsFor query: String, result resultBlock: @escaping (_ items: [Any]) -> Void)
    
    
    @objc optional  func inputView(_ inputView: AutoCompleteInputView, stringForObject object: Any, at index: Int) -> String
    // calculate the width of the view for the object (NSString or ACEAutocompleteItem)
    
    @objc optional  func inputView(_ inputView: AutoCompleteInputView, widthForObject object: Any) -> CGFloat
    // called when after the cell is created, to add custom subviews
    
    @objc optional  func inputView(_ inputView: AutoCompleteInputView, customize view: UIView)
    
    // called to set the object properties in the custom view
    @objc optional  func inputView(_ inputView: AutoCompleteInputView, setObject object: Any, forView view: UIView)
}


class AutoComleteCell : UITableViewCell {
    var separatorView:UIView?
}


class AutoCompleteInputView: UIView {
    
    var textField: UITextField? = nil
    var delegate: AutoCompleteDelegate?
    var dataSource: AutoCompleteDataSource?
    
    var font: UIFont? = UIFont.systemFont(ofSize: CGFloat(17.0))
    var textColor:UIColor? =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)//UIColor.black #colorLiteral(red: 0.7568627451, green: 0.8235294118, blue: 0.8823529412, alpha: 1)
    var inputViewBacKGroundColor: UIColor? = #colorLiteral(red: 0.6547438502, green: 0.7170516849, blue: 0.7922126651, alpha: 1)
    var sepratorColor: UIColor? = #colorLiteral(red: 0.7568627451, green: 0.8235294118, blue: 0.8823529412, alpha: 1)
    var suggestionListView:UITableView? = nil
    var suggestionList = [Any]()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(" NSCoding compliant")
    }
    
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    override  init(frame: CGRect ) {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: kDefaultHeight))
        
        // initializing tableView with Suggestion
        
        suggestionListView = UITableView.init(frame: CGRect(x: Double((self.bounds.size.width - self.bounds.size.height) / 2),
                                                            y: Double((self.bounds.size.height - self.bounds.size.width) / 2),
                                                            width: Double(self.bounds.size.height),
                                                            height: Double(self.bounds.size.width)) )
        
        // init the bar the hidden state
        self.isHidden = true
        
        suggestionListView?.register(AutoComleteCell.self, forCellReuseIdentifier: "Cell")
        suggestionListView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        suggestionListView?.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        
        suggestionListView?.showsVerticalScrollIndicator = false
        suggestionListView?.showsHorizontalScrollIndicator = false
        suggestionListView?.backgroundColor = sepratorColor//UIColor.clear
        suggestionListView?.separatorStyle = .none
        
        suggestionListView?.delegate = self
        suggestionListView?.dataSource = self
        
        // clean the rest of separators
        suggestionListView?.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 2))
        
        // Add TableView
        
        self.addSubview(suggestionListView!)
        
        
    }
    
    func textFieldDidChange(textField: UITextField) {
        var  query =  textField.text
        if ((query?.characters.count)! >= (self.dataSource?.minimumCharacters(toTrigger: self))!) {
            self.dataSource?.inputView(self, itemsFor: query!, result: { [weak self] (_ items: [Any]) -> Void in
                
                self?.suggestionList.removeAll()
                self?.suggestionList = items
                self?.suggestionListView?.reloadData()
            })
            
        }else{
            
            self.suggestionList.removeAll()
            self.suggestionListView?.reloadData()
            
        }
        
        
        
    }
    
    func show(_ show: Bool, withAnimation animated: Bool) {
        
        if (show && self.isHidden ) {
            // this is to remove the frst animation when the virtual keyboard will appear
            // use the hidden property to hide the bar wihout animations
            self.isHidden = false
        }
        
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.show(show, withAnimation: false)
                self?.isHidden = !show
            })
        }else{
            
            self.alpha = (show) ? 1.0 : 0.0
            self.isHidden = !show
            
        }
        
    }
    
    
    
    func stringForObject(atIndex index:NSInteger) -> String?{
        let object =   suggestionList[index]
        
        if (dataSource?.responds(to: #selector(AutoCompleteDataSource.inputView(_:stringForObject:at:))))! {
            
            return (dataSource?.inputView!(self, stringForObject: object, at: index))!
        }else if(object is AutoCompleteItem){
            
            return (object as! AutoCompleteItem).autoCompleteString()
            
        }else if (object is String){
            return object as? String
        }else{
            return nil
        }
        
    }
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (self.delegate?.responds(to: #function))! {
            return self.delegate!.textFieldShouldBeginEditing!(textField)
        }
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if  (self.delegate?.responds(to: #function))! {
            self.delegate!.textFieldDidBeginEditing!(textField)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        self.show(false, withAnimation: false)
        if (self.delegate?.responds(to: #function))! {
            return self.delegate!.textFieldShouldEndEditing!(textField)
        }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (self.delegate?.responds(to: #function))! {
            self.delegate?.textFieldDidEndEditing!(textField)
        }
    }
    
    
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        var  query = nsString?.replacingCharacters(in: range, with: string)
        
        if ((query?.characters.count)! >= (self.dataSource?.minimumCharacters(toTrigger: self))!) {
            
            self.dataSource?.inputView(self, itemsFor: query!, result: { [weak self] (_ items: [Any]) -> Void in
                
                self?.suggestionList.removeAll()
                self?.suggestionList = items
                self?.suggestionListView?.reloadData()
            })
            
        }else{
            
            self.suggestionList.removeAll()
            self.suggestionListView?.reloadData()
            
        }
        
        if (self.delegate?.responds(to: #function))! {
            return self.delegate!.textField!(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        return true
    }
    
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if (self.delegate?.responds(to: #function))! {
            return self.delegate!.textFieldShouldClear!(textField)
        }
        return false
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (self.delegate?.responds(to: #function))! {
            return self.delegate!.textFieldShouldReturn!(textField)
        }
        return false
    }
    
    
}


extension AutoCompleteInputView : UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (self.dataSource?.responds(to: #selector(AutoCompleteDataSource.inputView(_:widthForObject:))))! {
            return self.dataSource!.inputView!(self, widthForObject: self.suggestionList[indexPath.row])
            
        }else{
            var width:CGFloat
            
            let string = self.stringForObject(atIndex: indexPath.row) // var
            width = (string?.boundingRect(with: self.frame.size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: self.font ?? UIFont.boldSystemFont(ofSize: CGFloat(18.0))], context: nil).size.width)!
            width = CGFloat(ceilf(Float(width)))
            width += 1
            
            
            if width == 0 {
                return self.frame.size.width
            }
            
            // Some margin added
            return width + CGFloat((kDefaultMargin * 2) + 1.0)
        }
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.textField(self.textField!, didSelectObject: self.suggestionList[indexPath.row], in: self)
        self.show(false, withAnimation: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let suggestions = self.suggestionList.count
        self.show((suggestions > 0), withAnimation: true)
        return suggestions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var rotatedView: UIView? = nil
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AutoComleteCell
        cell.bounds = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.bounds.size.height), height: CGFloat(self.frame.size.height))
        cell.contentView.frame = cell.bounds
        cell.selectionStyle = .none
        cell.backgroundColor =  inputViewBacKGroundColor //UIColor.clear
        
        
        let frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(cell.bounds.size.height), height: CGFloat(cell.bounds.size.width)).insetBy(dx: CGFloat(kDefaultMargin), dy: CGFloat(kDefaultMargin))
        rotatedView = UIView(frame: frame)
        rotatedView?.tag = Int(kTagRotatedView)
        rotatedView?.center = cell.contentView.center
        rotatedView?.clipsToBounds = true
        rotatedView?.autoresizingMask = .flexibleHeight
        rotatedView?.transform = CGAffineTransform(rotationAngle: .pi / 2)
        cell.contentView.addSubview(rotatedView!)
        
        self.customize(rotatedView!)
        
        if cell.separatorView != nil {
            cell.separatorView?.removeFromSuperview()
        }
        
        
        cell.separatorView = UIView()
        let cellHeight: CGFloat =  self.tableView(suggestionListView!, heightForRowAt: indexPath)
        cell.separatorView?.frame = CGRect(x: CGFloat(cell.contentView.frame.origin.x), y: CGFloat(cellHeight - 1), width: CGFloat(cell.contentView.frame.size.width), height: CGFloat(1))
        cell.separatorView?.backgroundColor = sepratorColor
        
        cell.addSubview(cell.separatorView!)
        
        // customize the cell view if the data source support it, just use the text otherwise
        
        if (self.dataSource?.responds(to: #selector(AutoCompleteDataSource.inputView(_:setObject:forView:))))! {
            self.dataSource?.inputView!(self, setObject: self.suggestionList[indexPath.row], forView: rotatedView!)
        }else{
            let textLabel = (rotatedView?.viewWithTag(Int(kTagLabelView))! as! UILabel)
            // set the default properties
            textLabel.font = self.font
            textLabel.textColor =  self.textColor
            textLabel.text = self.stringForObject(atIndex: indexPath.row)!
            
            
            
        }
        
        return cell
    }
    
    
    func customize(_ rotatedView: UIView) {
        // customization
        if (self.dataSource?.responds(to: #selector(AutoCompleteDataSource.inputView(_:customize:))))! {
            self.dataSource?.inputView!(self, customize: rotatedView)
        }
        else {
            // create the label
            let textLabel = UILabel(frame: rotatedView.bounds)
            textLabel.tag = Int(kTagLabelView)
            textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            textLabel.backgroundColor = inputViewBacKGroundColor //#colorLiteral(red: 0.7565306425, green: 0.8242731094, blue: 0.8834246993, alpha: 1) //UIColor.blue
            rotatedView.addSubview(textLabel)
        }
    }
    
}


