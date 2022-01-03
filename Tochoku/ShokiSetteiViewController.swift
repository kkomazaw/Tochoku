//
//  ShokiSetteiViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/09/26.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit

class ShokiSetteiViewController: UIViewController {
    
    @IBOutlet var Sakuseisha:UISegmentedControl!
    @IBOutlet var Yushin:UISegmentedControl!
    @IBOutlet var Nicchoku:UISegmentedControl!
    @IBOutlet var DoyoNicchoku:UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.bool(forKey: "isSakuseisha") == true{
            Sakuseisha.selectedSegmentIndex = 0
        }
        else{
            Sakuseisha.selectedSegmentIndex = 1
        }
        if defaults.bool(forKey: "isYushin") == true{
            Yushin.selectedSegmentIndex = 0
        }
        else{
            Yushin.selectedSegmentIndex = 1
        }
        if defaults.bool(forKey: "isYushin") == true{
            Yushin.selectedSegmentIndex = 0
        }
        else{
            Yushin.selectedSegmentIndex = 1
        }
        if defaults.bool(forKey: "isNicchoku") == true{
            Nicchoku.selectedSegmentIndex = 0
        }
        else{
            Nicchoku.selectedSegmentIndex = 1
        }
        if defaults.bool(forKey: "isDoyoNicchoku") == true{
            DoyoNicchoku.selectedSegmentIndex = 0
        }
        else{
            DoyoNicchoku.selectedSegmentIndex = 1
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func myActionValueChange(){
        switch Sakuseisha.selectedSegmentIndex {
        case 0:
            isSakuseisha = true
        case 1:
            isSakuseisha = false
        default:
            break
        }
        switch Yushin.selectedSegmentIndex {
        case 0:
            isYushin = true
        case 1:
            isYushin = false
        default:
            break
        }
        switch Nicchoku.selectedSegmentIndex {
        case 0:
            isNicchoku = true
        case 1:
            isNicchoku = false
        default:
            break
        }
        switch DoyoNicchoku.selectedSegmentIndex {
        case 0:
            isDoyoNicchoku = true
        case 1:
            isDoyoNicchoku = false
        default:
            break
        }
        defaults.set(isSakuseisha, forKey: "isSakuseisha")
        defaults.set(isYushin, forKey: "isYushin")
        defaults.set(isNicchoku, forKey: "isNicchoku")
        defaults.set(isDoyoNicchoku, forKey: "isDoyoNicchoku")
    }
}
