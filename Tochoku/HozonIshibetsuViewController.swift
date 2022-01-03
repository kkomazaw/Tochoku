//
//  HozonIshibetsuViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2019/07/21.
//  Copyright © 2019 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class HozonIshibetsuViewController: UIViewController {
    
    @IBOutlet var DetailText:UITextView!
    
    var thisClassComponents = DateComponents()
    var savedArray:[TochokuData] = []
    var hozonArray:[HozonData] = []
    var anIndex = 0
    var dayInterval = 0
    
    typealias HozonScore = (aDay: Int, type: TochokuType, yScore: Int, name: String)
    var b = Array<HozonScore>()

    override func viewDidLoad() {
        super.viewDidLoad()
        let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            
            let sortDescripter = NSSortDescriptor(key: "torokubi", ascending: true)
            let fetchRequest: NSFetchRequest<TochokuData> = TochokuData.fetchRequest()
            fetchRequest.sortDescriptors = [sortDescripter]
            savedArray = try myContext.fetch(fetchRequest)
            let sortDescripter2 = NSSortDescriptor(key: "month", ascending: false)
            let fetchRequest2: NSFetchRequest<HozonData> = HozonData.fetchRequest()
            fetchRequest2.sortDescriptors = [sortDescripter2]
            hozonArray = try myContext.fetch(fetchRequest2)
        }
        catch {
            print("Fetching Failed.")
        }
        //tochokuStringはKekkaViewControllerのfunc makeView()で作られたもの
        let enterSeparatedArray = tochokuString.components(separatedBy: "\n")
        let yearMonth = enterSeparatedArray.filter{$0.contains("年") && $0.contains("月")}
        let dateArr = yearMonth[0].components(separatedBy: "年")
        let month = dateArr[1].components(separatedBy: "月")[0]
        let tochokuContainsArray = enterSeparatedArray.filter{$0.contains("夕診") || $0.contains("日直") || $0.contains("当直")}.filter{$0.contains("(") && $0.contains(")")}
        let day = tochokuContainsArray[0].components(separatedBy: "日")[0]
        thisClassComponents.year = Int(dateArr[0])
        thisClassComponents.month = Int(month)
        thisClassComponents.day = Int(day)
        let startDay = cal.date(from: thisClassComponents)
        thisClassComponents.day = 1
        let selectedDay = cal.date(from: thisClassComponents)
        dayInterval = (Calendar.current.dateComponents([.day], from: selectedDay!, to: startDay!)).day!
        for i in 0 ..< tochokuContainsArray.count{
            var subArr = [String]()
            if tochokuContainsArray[i].contains("\t"){
                subArr = tochokuContainsArray[i].components(separatedBy: "\t")
            }
            else{
                subArr = tochokuContainsArray[i].components(separatedBy: " ").filter{$0 != " " && $0 != ""}
            }
            if let index = subArr.firstIndex(where: {$0.contains("夕診")}){
                if let yScore = savedArray.firstIndex(where: {$0.name == subArr[index + 1]}){
                    b.append((i + 1,.yushin,yScore,subArr[index + 1]))
                }
                else{
                    b.append((i + 1,.yushin,-1 ,subArr[index + 1]))
                }
            }//if let index = subArr.index(where: {$0.contains("夕診")})
            if let index = subArr.firstIndex(where: {$0.contains("当直")}){
                if let yScore = savedArray.firstIndex(where: {$0.name == subArr[index + 1]}){
                    b.append((i + 1,.tochoku,yScore,subArr[index + 1]))
                }
                else{
                    b.append((i + 1,.tochoku,-1 ,subArr[index + 1]))
                }
            }//if let index = subArr.index(where: {$0.contains("当直")})
            if let index = subArr.firstIndex(where: {$0.contains("日直")}){
                let subsubArr = subArr[index + 1].components(separatedBy: "/")
                if let yScore = savedArray.firstIndex(where: {$0.name == subsubArr[0]}){
                    b.append((i + 1,.nicchoku,yScore,subsubArr[0]))
                }
                else{
                    b.append((i + 1,.nicchoku,-1 ,subsubArr[0]))
                }
                if let yScore = savedArray.firstIndex(where: {$0.name == subsubArr[1]}){
                    b.append((i + 1,.tochoku,yScore,subsubArr[1]))
                }
                else{
                    b.append((i + 1,.tochoku,-1 ,subsubArr[1]))
                }
            }//if let index = subArr.index(where: {$0.contains("日直")})
        }//for i in 0 ..< tochokuContainsArray.count
        var localComponents = DateComponents()
        localComponents.year = components.year
        localComponents.month = components.month
        let hinichiFormatter = DateFormatter()
        hinichiFormatter.locale = Locale(identifier: "ja_JP")
        hinichiFormatter.dateFormat = "d日"
        var hozonDetailString = ""
        for i in 0 ..< savedArray.count {
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
                hozonDetailString += "\(savedArray[i].name!): 夕診 \(yushinKaisu)回(希望\(savedArray[i].yushinkai)) \(nittochokuString) \(tochokukaisu)回(希望\(savedArray[i].tochokukai))\n"
            }
            else{
                hozonDetailString += "\(savedArray[i].name!): \(nittochokuString) \(tochokukaisu)回(希望\(savedArray[i].tochokukai))\n"
            }
            for j in filteredArray{
                localComponents.day = j.aDay + dayInterval
                let selectedDay = cal.date(from: localComponents)
                let hinichiString = hinichiFormatter.string(from: selectedDay!)
                hozonDetailString += " \(hinichiString) \(j.type.rawValue)/"
            }//for j in filteredArray
            hozonDetailString += "\n\n"
        }//for i in 0 ..< savedArray.count
        DetailText.text = hozonDetailString
    }//override func viewDidLoad()
    
    
    
}//class HozonIshibetsuViewController: UIViewController
