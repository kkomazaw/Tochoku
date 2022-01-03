//
//  DetailViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/07/01.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet var DetailText:UITextView!
    @IBOutlet var copyButton:UIBarButtonItem!
    @IBOutlet var myToolBar:UIToolbar!
    
    var savedArray:[TochokuData] = []

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
    }
    
    @IBAction func myActionCopy(){
        let activityItems = [DetailText.text as Any]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }//@IBAction func myActionCopy()
    
    override func viewWillAppear(_ animated: Bool) {
        if bufferCount == 0{
            return
        }
        let selectedDay = cal.date(from: components)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "YYYY年M月"
        let monthString2 = selectedDateFormatter.string(from: selectedDay!)
        let buffer = bufferScores.filter{$0.month == monthString2}
        let b = buffer[bufferCount - 1].yusenTuple
        let startDay = buffer[bufferCount - 1].firstDayDate
        let dayInterval = (Calendar.current.dateComponents([.day], from: selectedDay!, to: startDay)).day
        detailString = ""
        var localComponents = DateComponents()
        localComponents.year = components.year
        localComponents.month = components.month
        let hinichiFormatter = DateFormatter()
        hinichiFormatter.locale = Locale(identifier: "ja_JP")
        hinichiFormatter.dateFormat = "d日"
        for i in 0 ..< savedArray.count{
            let filteredArray = b.filter{$0.yScore == i}
            var yushinKaisu = 0
            var tochokukaisu = 0
            var nittochokuString = "日当直"
            if !isNicchoku{
                nittochokuString = "当直"
            }
            yushinKaisu = (filteredArray.filter{$0.type == .yushin}).count
            tochokukaisu = (filteredArray.filter{$0.type != .yushin}).count
            if isYushin{
                detailString += "\(savedArray[i].name!): 夕診 \(yushinKaisu)回(希望\(savedArray[i].yushinkai)) \(nittochokuString) \(tochokukaisu)回(希望\(savedArray[i].tochokukai))\n"
            }
            else{
                detailString += "\(savedArray[i].name!): \(nittochokuString) \(tochokukaisu)回(希望\(savedArray[i].tochokukai))\n"
            }
            for j in filteredArray{
                localComponents.day = j.aDay + dayInterval!
                let selectedDay = cal.date(from: localComponents)
                let hinichiString = hinichiFormatter.string(from: selectedDay!)
                detailString += " \(hinichiString) \(j.type.rawValue)/"
            }//for j in filteredArray
            detailString += "\n\n"
        }//for i in 0 ..< doctorCount
        if bufferCount >= 1{
            DetailText.text = detailString
            // Do any additional setup after loading the view.
        }
    }//override func viewWillAppear(_ animated: Bool)

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
