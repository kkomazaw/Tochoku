//
//  IshiTorokuViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/02/27.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class IshiTorokuViewController: UIViewController {
    
    @IBOutlet var Ishimei:UITextField!
    @IBOutlet var TochokuKaisu:UITextField!
    @IBOutlet var YushinKaisu:UITextField!
    @IBOutlet var TorokuButton:UIButton!
    @IBOutlet var YushinkaisuLabel:UILabel!
    
    var fetchedArray:[TochokuData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Ishimei.becomeFirstResponder()
        if isYushin{
            YushinKaisu.isHidden = false
            YushinkaisuLabel.isHidden = false
        }
        else{
            YushinKaisu.isHidden = true
            YushinkaisuLabel.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func myActionToroku(){
        if (Ishimei.text?.isEmpty)!{
            return
        }
        let ishimeiText = Ishimei.text?.replacingOccurrences(of: " ", with: "")
        let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
        let fetchRequest:NSFetchRequest<TochokuData> = TochokuData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format:"name = %@", ishimeiText!)
        fetchedArray = try myContext.fetch(fetchRequest)
        }
        catch{
            print("fetching failed")
        }
        if fetchedArray.count > 0{
            let titleString = "医師名重複"
            let messageString = "同名の医師が既に登録されています。名称を変更して下さい。"
            let alert: UIAlertController = UIAlertController(title:titleString,message: messageString,preferredStyle: UIAlertController.Style.alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK",style: UIAlertAction.Style.default,handler:{(action:UIAlertAction!) -> Void in
            })
            alert.addAction(okAction)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        else{
            let tochokuData:TochokuData = TochokuData(context: myContext)
            tochokuData.name = ishimeiText
            tochokuData.torokubi = Date()
            var tochokukai = 0
            if let i = Int(TochokuKaisu.text!){
                tochokukai = i
            }
            var yushinkai = 0
            if let i = Int(YushinKaisu.text!){
                yushinkai = i
            }
            tochokuData.tochokukai = Int64(tochokukai)
            tochokuData.yushinkai = Int64(yushinkai)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }//else
        Ishimei.text = ""
        TochokuKaisu.text = ""
        YushinKaisu.text = ""
        Ishimei.becomeFirstResponder()
    }//@IBAction func myActionToroku()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
