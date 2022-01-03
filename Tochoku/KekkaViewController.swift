//
//  KekkaViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/04/15.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class KekkaViewController: UIViewController {
    
    @IBOutlet var KekkaText:UITextView!
    @IBOutlet var copyButton:UIBarButtonItem!
    @IBOutlet var zenkohoButton:UIBarButtonItem!
    @IBOutlet var tsugikohoButton:UIBarButtonItem!
    @IBOutlet var shuseiButton:UIBarButtonItem!
    @IBOutlet var sakujoButton:UIBarButtonItem!
    @IBOutlet var hozonButton:UIBarButtonItem!
    @IBOutlet var myToolBar:UIToolbar!
    
    var savedArray:[TochokuData] = []
    var bufferIndex = 0
    
    //typealias BufferScore = (month: String, serial: Int, yusenTuple: Array<YusenScore>, firstDayDate: Date, lastDayDate: Date)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        //iPhone X 以降で、以下のコードが実行されます
        if height > 800.0 && height < 1000.0 {
            myToolBar.frame = CGRect(x: 0, y: height * 0.92, width: width, height: height * 0.055)
        }//if height > 800.0 && height < 1000.0
        let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            
            let sortDescripter = NSSortDescriptor(key: "torokubi", ascending: true)
            let fetchRequest: NSFetchRequest<TochokuData> = TochokuData.fetchRequest()
            fetchRequest.sortDescriptors = [sortDescripter]
            savedArray = try myContext.fetch(fetchRequest)
        }
        catch {
            print("Fetching Failed.")
        }
        selectedComponents.year = components.year
        selectedComponents.month = components.month
        selectedComponents.day = 1
        let selectedDay = cal.date(from: selectedComponents)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "YYYY年M月"
        let monthString2 = selectedDateFormatter.string(from: selectedDay!)
        bufferCount = bufferScores.filter{$0.month == monthString2}.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        makeView()
    }
    
    func makeView(){
        if bufferCount == 0{
            return
        }
        tochokuString = ""
        let selectedDay = cal.date(from: components)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "YYYY年M月"
        let monthString2 = selectedDateFormatter.string(from: selectedDay!)
        let buffer = bufferScores.filter{$0.month == monthString2}
        let b = buffer[bufferCount - 1].yusenTuple
        print("bufferCount=\(bufferCount), serial=\(buffer[bufferCount - 1].serial)")
        let startDay = buffer[bufferCount - 1].firstDayDate
        let monthStringOfStartDay = selectedDateFormatter.string(from: startDay)
        tochokuString += monthStringOfStartDay + "\t\n"
        let dayInterval = (Calendar.current.dateComponents([.day], from: selectedDay!, to: startDay)).day
        for i in 0 ..< b.count{
            var localComponents = DateComponents()
            localComponents.year = components.year
            localComponents.month = components.month
            localComponents.day = b[i].aDay + dayInterval!
            let selectedDay = cal.date(from: localComponents)
            let selectedDateFormatter = DateFormatter()
            selectedDateFormatter.locale = Locale(identifier: "ja_JP")
            selectedDateFormatter.dateFormat = "EE"
            let weekDayString = selectedDateFormatter.string(from: selectedDay!)
            let hinichiFormatter = DateFormatter()
            hinichiFormatter.locale = Locale(identifier: "ja_JP")
            hinichiFormatter.dateFormat = "d日"
            let hinichiString = hinichiFormatter.string(from: selectedDay!)
            var tabString = ""
            if b[i].type != .yushin{
                if isYushin{
                    tabString = "\t\t"
                }
                else{
                    tabString = ""
                }
            }
            var nicchokuSlash = "\t"
            var tochokuOrSlash = "当直\t"
            if i >= 1, b[i - 1].type == .nicchoku{
                tochokuOrSlash = ""
            }
            if b[i].type == .nicchoku{
                nicchokuSlash = "/"
            }
            if i >= 1{
                if b[i - 1].aDay != b[i].aDay{
                    tochokuString += "\(hinichiString)\t(\(weekDayString))\t\(tabString)\(b[i].type.rawValue)\t\(savedArray[b[i].yScore].name ?? "")\(nicchokuSlash)"
                }
                else{
                    tochokuString += "\(tochokuOrSlash)\(savedArray[b[i].yScore].name ?? "")\t"
                }
            }//if i >= 1
            else{
                tochokuString += "\(hinichiString)\t(\(weekDayString))\t\(tabString)\(b[i].type.rawValue)\t\(savedArray[b[i].yScore].name ?? "")\(nicchokuSlash)"
            }
            if i <= b.count - 2{
                if b[i].aDay != b[i + 1].aDay{
                    tochokuString += "\n"
                }
            }
        }
        KekkaText.text = tochokuString
        self.navigationItem.title = "当直案 \(bufferCount)/\(buffer.count)"
        let bCount = bufferScores.filter{$0.month == monthString2}.count
        if bCount == 0{
            self.shuseiButton.isEnabled = false
            self.shuseiButton.tintColor = UIColor.clear
        }
        else{
            self.shuseiButton.isEnabled = true
            self.shuseiButton.tintColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        }
        print("\n")
        print(tochokuString)
    }//func makeView()
    
    @IBAction func myActionCopy(){
        let activityItems = [KekkaText.text as Any]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }//@IBAction func myActionCopy()
    
    @IBAction func myActionZenkoho(){
        let selectedDay = cal.date(from: components)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "YYYY年M月"
        let monthString2 = selectedDateFormatter.string(from: selectedDay!)
        let bCount = bufferScores.filter{$0.month == monthString2}.count
        if bCount >= 2, bufferCount >= 2{
            bufferCount += -1
            makeView()
        }
    }//@IBAction func myActionZenkoho()
    
    @IBAction func myActionTsugikoho(){
        let selectedDay = cal.date(from: components)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "YYYY年M月"
        let monthString2 = selectedDateFormatter.string(from: selectedDay!)
        let bCount = bufferScores.filter{$0.month == monthString2}.count
        if bCount >= 2, bufferCount <= bCount - 1{
            bufferCount += 1
            makeView()
        }
    }//@IBAction func myActionTsugikoho()
    
    @IBAction func myActionSakujo(){
        if bufferCount == 0{
            return
        }
        let selectedDay = cal.date(from: components)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "YYYY年M月"
        let monthString2 = selectedDateFormatter.string(from: selectedDay!)
        if let i = bufferScores.firstIndex(where: {$0.month == monthString2 && $0.serial == bufferCount - 1}){
            bufferIndex = i
        }
        bufferScores.remove(at: bufferIndex)
        let bCount = bufferScores.filter{$0.month == monthString2}.count
        if bufferCount > bCount{
            bufferCount = bCount
        }
        if bufferCount >= 1{
            makeView()
        }
        else{
            KekkaText.text = ""
            self.navigationItem.title = "当直案 0/0"
        }
        if bCount == 0{
            self.shuseiButton.isEnabled = false
            self.shuseiButton.tintColor = UIColor.clear
            self.hozonButton.isEnabled = false
            self.hozonButton.tintColor = UIColor.clear
        }
        else{
            self.shuseiButton.isEnabled = true
            self.shuseiButton.tintColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            self.hozonButton.isEnabled = true
            self.hozonButton.tintColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        }
    }//@IBAction func myActionSakujo()
    
    @IBAction func myActionHozon(){
        let titleString = "保存"
        let messageString = "この当直表を保存しますか？"
        let alert: UIAlertController = UIAlertController(title:titleString,message: messageString,preferredStyle: UIAlertController.Style.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK",style: UIAlertAction.Style.default,handler:{(action:UIAlertAction!) -> Void in
            let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let hozonData:HozonData = HozonData(context: myContext)
            hozonData.month = Date()
            hozonData.tochokuhyo = tochokuString
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.performSegue(withIdentifier: "toHozon2", sender: true)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        KekkaText.text = ""
    }
    
}
