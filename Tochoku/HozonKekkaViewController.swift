//
//  HozonKekkaViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/09/17.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit

class HozonKekkaViewController: UIViewController {
    
    @IBOutlet var Hozonkekka:UITextView!
    @IBOutlet var copyButton:UIBarButtonItem!
    @IBOutlet var shuseiButton:UIBarButtonItem!
    @IBOutlet var calendarLink:UIBarButtonItem!
    @IBOutlet var myToolBar:UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        //iPhone X 以降で、以下のコードが実行されます
        if height > 800.0 && height < 1000.0 {
            myToolBar.frame = CGRect(x: 0, y: height * 0.92, width: width, height: height * 0.055)
        }//if height > 800.0 && height < 1000.0
        // Do any additional setup after loading the view.
    }
    
    @IBAction func myActionCopy(){
        let activityItems = [Hozonkekka.text as Any]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }//@IBAction func myActionCopy()
    
    @IBAction func myActionLink(){
        guard Hozonkekka.text != "" else { return }
        tochokuString = Hozonkekka.text
        performSegue(withIdentifier: "toSakuseishaLink", sender: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Hozonkekka.text = tochokuString
        if !isSakuseisha{
            shuseiButton.isEnabled = false
            shuseiButton.tintColor = UIColor.clear
        }
        else{
            shuseiButton.isEnabled = true
            shuseiButton.tintColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

