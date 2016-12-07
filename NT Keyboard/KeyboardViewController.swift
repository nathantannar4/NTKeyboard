//
//  KeyboardViewController.swift
//  NT Keyboard
//
//  Created by Nathan Tannar on 12/5/16.
//  Copyright © 2016 Nathan Tannar. All rights reserved.
//

import UIKit
import Foundation

enum PhoneOrientation {
    case portrait
    case landscape
}

enum NTKeyboardKeyType {
    case letter
    case number
    case symbol
    case shift
    case spacebar
    case backspace
    case returnKey
    case nextKeyboard
}

enum NTKeyboardState {
    case lowercase
    case uppercase
    case numbers
    case symbols
}

class NTKeyboardKey: UIButton {
    
    var type: NTKeyboardKeyType!
    var differentDisplayValue: String!
    var value: String!
    var image: UIImage?
    
    convenience init(type: NTKeyboardKeyType, value: String, differentDisplayValue: String?, image: UIImage?) {
        self.init()
        self.type = type
        self.value = value
        self.differentDisplayValue = differentDisplayValue ?? value
        self.image = image
        self.setProperties()
    }
    
    func setProperties() {
        if self.image == nil {
            self.setTitle(self.differentDisplayValue, for: .normal)
        } else {
            self.setImage(UIImage.resizeImage(image: self.image!, width: 30, height: 30)?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.tintColor = UIColor.darkGray
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        self.setTitleColor(UIColor.darkGray, for: .normal)
        self.layer.cornerRadius = 5
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.1
        self.layer.shadowColor = UIColor.black.cgColor
    }
}

class KeyboardViewController: UIInputViewController {
    
    private var keyboardKeys: [Int : Array<NTKeyboardKey>] = [:]
    private var keyboardViews: Array<UIView> = [UIView]()
    public var phoneOrientation: PhoneOrientation = .landscape
    public var numberOfRows: Int = 0
    private var rowHeight: CGFloat = 40
    public var currentState: NTKeyboardState = .lowercase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numberOfRows = 4
        self.prepareNTKeyboardKeys()
    }
    
    func createButton(type: NTKeyboardKeyType, value: String, differentDisplayValue: String?, image: UIImage?) -> NTKeyboardKey {
        let button = NTKeyboardKey(type: type, value: value, differentDisplayValue: differentDisplayValue, image: image)
        switch type {
        case .letter:
            button.addTarget(self, action: #selector(keyPressed(sender:)), for: .touchUpInside)
        case .nextKeyboard:
            button.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .touchUpInside)
        default:
            break
        }
        return button
    }
    
    public func prepareNTKeyboardKeys() {
        
        self.rowHeight = 210 / CGFloat(self.numberOfRows)
        
        var keyboardLetterKeys: [Int : Array<String>] = [ 0 : ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                                                          1 : ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
                                                          2 : ["CL", "Z", "X", "C", "V", "B", "N", "M", "BS"],
                                                          3 : ["CHANGE", "SPACE", "RETURN"]]
     
        for row in 0...self.numberOfRows - 1 {
            let rowView = UIView(frame: CGRect(x: 0, y: CGFloat(row) * rowHeight, width: UIScreen.main.bounds.width, height: rowHeight))
            self.keyboardKeys[row] = self.createButtons(titles: keyboardLetterKeys[row]!)
            for button in self.keyboardKeys[row]! {
                rowView.addSubview(button)
            }
            self.view.addSubview(rowView)
            self.addConstraints(buttons: self.keyboardKeys[row]!, containingView: rowView)
        }

    }
    
    func createButtons(titles: [String]) -> [NTKeyboardKey] {
        var buttons = [NTKeyboardKey]()
        for title in titles {
            if title == "CHANGE" {
                let button = NTKeyboardKey(type: .nextKeyboard, value: title, differentDisplayValue: nil, image: #imageLiteral(resourceName: "Globe"))
                button.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
                buttons.append(button)
            } else if title == "CL" {
                let button = NTKeyboardKey(type: .shift, value: title, differentDisplayValue: nil, image: #imageLiteral(resourceName: "Shift Up"))
                button.addTarget(self, action: #selector(keyPressed(sender:)), for: .touchUpInside)
                buttons.append(button)
            } else if title == "BS" {
                let button = NTKeyboardKey(type: .backspace, value: title, differentDisplayValue: nil, image: #imageLiteral(resourceName: "Backspace"))
                button.addTarget(self, action: #selector(keyPressed(sender:)), for: .touchUpInside)
                buttons.append(button)
            } else if title == "SPACE" {
                let button = NTKeyboardKey(type: .spacebar, value: "", differentDisplayValue: "", image: nil)
                button.addTarget(self, action: #selector(keyPressed(sender:)), for: .touchUpInside)
                buttons.append(button)
            } else if title == "RETURN" {
                let button = NTKeyboardKey(type: .returnKey, value: title, differentDisplayValue: "Return", image: nil)
                button.addTarget(self, action: #selector(keyPressed(sender:)), for: .touchUpInside)
                buttons.append(button)
            } else {
                let button = NTKeyboardKey(type: .letter, value: title, differentDisplayValue: nil, image: nil)
                button.addTarget(self, action: #selector(keyPressed(sender:)), for: .touchUpInside)
                buttons.append(button)
            }
        }
        return buttons
    }
    
    func addConstraints(buttons: [UIButton], containingView: UIView){
        for button in buttons {
            let index = buttons.index(of: button)!
            
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: containingView, attribute: .top, multiplier: 1.0, constant: 5)
            
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: containingView, attribute: .bottom, multiplier: 1.0, constant: -1)
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: containingView, attribute: .left, multiplier: 1.0, constant: 3)
            } else{
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: buttons[index-1], attribute: .right, multiplier: 1.0, constant: 3)
                
                let widthConstraint = NSLayoutConstraint(item: buttons[0], attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: 0)
                
                containingView.addConstraint(widthConstraint)
            }
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == buttons.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: containingView, attribute: .right, multiplier: 1.0, constant: -3)
                
            } else{
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: buttons[index+1], attribute: .left, multiplier: 1.0, constant: -3)
            }
            
            containingView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func keyPressed(sender: NTKeyboardKey) {
        let type = sender.type!
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        switch type {
        case .shift :
            var newState: NTKeyboardState!
            for row in 0...self.keyboardKeys.count - 1 {
                for key in self.keyboardKeys[row]! {
                    if key.type == .letter {
                        if self.currentState == .uppercase {
                            key.value = key.value!.lowercased()
                            key.differentDisplayValue = key.differentDisplayValue!.lowercased()
                            key.setTitle(key.differentDisplayValue, for: .normal)
                            newState = .lowercase
                        } else if self.currentState == .lowercase {
                            key.value = key.value!.uppercased()
                            key.differentDisplayValue = key.differentDisplayValue!.uppercased()
                            key.setTitle(key.differentDisplayValue, for: .normal)
                            newState = .uppercase
                        }
                    }
                }
            }
            self.currentState = newState
        case .backspace :
            proxy.deleteBackward()
        case .returnKey :
            proxy.insertText("\n")
        case .spacebar :
            proxy.insertText(" ")
        case .nextKeyboard :
            self.advanceToNextInputMode()
        default:
            proxy.insertText(sender.value!)
        }
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
    }
    
}

// Resize Image
extension UIImage {
    class func resizeImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage? {
        var newImage = image
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        newImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
