//
//  ViewController.swift
//  NTKeyboard
//
//  Created by Nathan Tannar on 12/5/16.
//  Copyright © 2016 Nathan Tannar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var keyboardLetterKeys: [Int : [String]] = [ 0 : ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                                                     1 : ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
                                                     2 : ["CL", "Z", "X", "C", "V", "B", "N", "M", "BS"],
                                                     3 : ["CHANGE", "SPACE", "RETURN"]]
        for row in 0...keyboardLetterKeys.count - 1 {
            print(keyboardLetterKeys[row]!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

