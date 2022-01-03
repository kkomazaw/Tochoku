//
//  JujishaUketoriViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/11/30.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class JujishaUketoriViewController: UIViewController {
    
    @IBOutlet var KekkaText:UITextView!
    @IBOutlet var copyButton:UIBarButtonItem!
    @IBOutlet var hozonButton:UIBarButtonItem!
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
    }//override func viewDidLoad()
    
    @IBAction func myActionCopy(){
        let activityItems = [KekkaText.text as Any]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }//@IBAction func myActionCopy()
    
    @IBAction func myActionHozon(){
        guard KekkaText.text != "" else { return }
        let titleString = "保存"
        let messageString = "この当直表を確定して保存しますか？"
        let alert: UIAlertController = UIAlertController(title:titleString,message: messageString,preferredStyle: UIAlertController.Style.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK",style: UIAlertAction.Style.default,handler:{(action:UIAlertAction!) -> Void in
            let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let hozonData:HozonData = HozonData(context: myContext)
            hozonData.month = Date()
            hozonData.tochokuhyo = self.KekkaText.text
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.performSegue(withIdentifier: "toHozon3", sender: true)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル",
                                                        style: UIAlertAction.Style.cancel,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }//@IBAction func myActionHozon()
   
    @IBAction func myActionLink(){
        guard KekkaText.text != "" else { return }
        tochokuString = KekkaText.text
        performSegue(withIdentifier: "toJujishaLink", sender: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}//class JujishaUketoriViewController: UIViewController
