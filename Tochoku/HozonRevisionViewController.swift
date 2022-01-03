//
//  HozonRevisionViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/09/22.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class HozonRevisionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var thisClassComponents = DateComponents()
    var savedArray:[TochokuData] = []
    var hozonArray:[HozonData] = []
    var isFixed:[Bool] = []
    var isChangable:[Bool] = []
    var anIndex = 0
    var dayInterval = 0
    
    typealias HozonScore = (aDay: Int, type: TochokuType, yScore: Int, name: String)
    var b = Array<HozonScore>()
    
    @IBOutlet var selector:UISegmentedControl!
    @IBOutlet var myToolBar:UIToolbar!

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
        isFixed = [Bool](repeating: true, count: b.count)
        isChangable = [Bool](repeating: false, count: b.count)
    }//override func viewDidLoad()
    
    func hozonDataRevision(){
        let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            let sortDescripter2 = NSSortDescriptor(key: "month", ascending: false)
            let fetchRequest2: NSFetchRequest<HozonData> = HozonData.fetchRequest()
            fetchRequest2.sortDescriptors = [sortDescripter2]
            hozonArray = try myContext.fetch(fetchRequest2)
        }
        catch {
            print("Fetching Failed.")
        }
        tochokuString = ""
        thisClassComponents.day = 1  + dayInterval
        let selectedDay = cal.date(from: thisClassComponents)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "YYYY年M月"
        let monthString2 = selectedDateFormatter.string(from: selectedDay!)
        
        tochokuString += monthString2 + "\t\n"
        let hinichiFormatter = DateFormatter()
        hinichiFormatter.locale = Locale(identifier: "ja_JP")
        hinichiFormatter.dateFormat = "d日"
        for i in 0 ..< b.count{
            thisClassComponents.day = b[i].aDay + dayInterval
            let selectedDay = cal.date(from: thisClassComponents)
            let originalHinichi = hinichiFormatter.string(from: selectedDay!)
            let selectedDateFormatter = DateFormatter()
            selectedDateFormatter.locale = Locale(identifier: "ja_JP")
            selectedDateFormatter.dateFormat = "EE"
            let weekDayString = selectedDateFormatter.string(from: selectedDay!)
            var tabString = ""
            if b[i].type != .yushin{
                tabString = "\t\t"
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
                    tochokuString += "\(originalHinichi)\t(\(weekDayString))\t\(tabString)\(b[i].type.rawValue)\t\(b[i].name )\(nicchokuSlash)"
                }
                else{
                    tochokuString += "\(tochokuOrSlash)\(b[i].name )\t"
                }
            }//if i >= 1
            else{
                tochokuString += "\(originalHinichi)\t(\(weekDayString))\t\(tabString)\(b[i].type.rawValue)\t\(b[i].name )\(nicchokuSlash)"
            }
            if i <= b.count - 2{
                if b[i].aDay != b[i + 1].aDay{
                    tochokuString += "\n"
                }
            }
        }
        hozonArray[hozonIndex].tochokuhyo = tochokuString
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }//func hozonDataRevision()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return b.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Name", for: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        let day = b[indexPath.row].aDay + dayInterval
        let type = b[indexPath.row].type
        let name = b[indexPath.row].name
        thisClassComponents.day = day
        let selectedDay = cal.date(from: thisClassComponents)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "M月d日 (EE)"
        let dayString = selectedDateFormatter.string(from: selectedDay!)
        selectedDateFormatter.dateFormat = "yyyy年M月d日"
        let kibobiString = selectedDateFormatter.string(from: selectedDay!)
        cell.textLabel!.text = "\(dayString) \(type.rawValue) \(name )"
        if b[indexPath.row].yScore != -1{
            switch type {
            case .yushin:
                if let l = savedArray[b[indexPath.row].yScore].yushinKibo, let _ = l.range(of: kibobiString){
                    cell.textLabel!.text = "\(dayString) \(type.rawValue) \(name) (希望)"
                }
            case .nicchoku:
                if let l = savedArray[b[indexPath.row].yScore].nicchokuKibo, let _ = l.range(of: kibobiString){
                    cell.textLabel!.text = "\(dayString) \(type.rawValue) \(name) (希望)"
                }
            case .tochoku:
                if let l = savedArray[b[indexPath.row].yScore].tochokuKibo, let _ = l.range(of: kibobiString){
                    cell.textLabel!.text = "\(dayString) \(type.rawValue) \(name) (希望)"
                }
            }//switch type
        }//if b[indexPath.row].yScore != -1
        if isFixed[indexPath.row]{
            cell.detailTextLabel?.text = ""
        }
        else{
            switch selector.selectedSegmentIndex{
            case 0:
                cell.detailTextLabel?.text = "※交換"
            case 1:
                cell.detailTextLabel?.text = "※委譲"
            default:
                break
            }//switch selector.selectedSegmentIndex
        }//else
        if isFixed[indexPath.row], isChangable[indexPath.row]{
            switch selector.selectedSegmentIndex{
            case 0:
                cell.detailTextLabel?.text = "⇄交換可"
            case 1:
                cell.detailTextLabel?.text = "譲受可"
            default:
                break
            }//switch selector.selectedSegmentIndex
        }//if isFixed[indexPath.row] == true, isChangable[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.minimumScaleFactor = 0.1
        cell.detailTextLabel?.minimumScaleFactor = 0.5
        return cell
    }//func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexDay = b[indexPath.row].aDay + dayInterval
        let indexType = b[indexPath.row].type
        let indexID = b[indexPath.row].yScore
        let indexName = b[indexPath.row].name
        thisClassComponents.day = indexDay
        let selectedDay = cal.date(from: thisClassComponents)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "yyyy年M月d日"
        let indexString = selectedDateFormatter.string(from: selectedDay!)
        var myFlag = 0
        if selector.selectedSegmentIndex == 0, isFixed[indexPath.row], isChangable[indexPath.row] == false{
            anIndex = indexPath.row
            myFlag = 1
        }
        if isFixed[indexPath.row] == false{
            myFlag = 2
        }
        if selector.selectedSegmentIndex == 0, isChangable[indexPath.row]{
            myFlag = 3
        }
        if selector.selectedSegmentIndex == 1, isFixed[indexPath.row], isChangable[indexPath.row] == false{
            anIndex = indexPath.row
            myFlag = 4
        }
        if selector.selectedSegmentIndex == 1, isChangable[indexPath.row]{
            myFlag = 5
        }
        switch myFlag {
        case 1://selector:0, isFixed:true, isChangable:false
            isFixed = [Bool](repeating: true, count: b.count)
            isChangable = [Bool](repeating: false, count: b.count)
            isFixed[indexPath.row] = false
            for i in 0 ..< b.count{
                if i == indexPath.row{
                    continue
                }
                let candidateDay = b[i].aDay + dayInterval
                let candidateType = b[i].type
                let candidateID = b[i].yScore
                let candidateName = b[i].name
                thisClassComponents.day = candidateDay
                let cDay = cal.date(from: thisClassComponents)
                let candidateString = selectedDateFormatter.string(from: cDay!)
                if indexName == candidateName{
                    continue
                }
                if indexType == .yushin, candidateType == .yushin{
                    isChangable[i] = true
                    if candidateID != -1, let k = savedArray[candidateID].yushinFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                    if indexID != -1, let k = savedArray[indexID].yushinFuka, let _ = k.range(of: candidateString){
                        isChangable[i] = false
                    }
                }//if indexType == .yushin, candidateType == .yushin
                if indexType == .tochoku, candidateType == .tochoku{
                    isChangable[i] = true
                    if candidateID != -1, let k = savedArray[candidateID].tochokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                    if indexID != -1, let k = savedArray[indexID].tochokuFuka, let _ = k.range(of: candidateString){
                        isChangable[i] = false
                    }
                }//if indexType == .tochoku, candidateType == .tochoku
                if indexType == .nicchoku, candidateType == .tochoku{
                    isChangable[i] = true
                    if candidateID != -1, let k = savedArray[candidateID].nicchokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                    if indexID != -1, let k = savedArray[indexID].tochokuFuka, let _ = k.range(of: candidateString){
                        isChangable[i] = false
                    }
                }//if indexType == .nicchoku, candidateType == .tochoku
                if indexType == .tochoku, candidateType == .nicchoku{
                    isChangable[i] = true
                    if candidateID != -1, let k = savedArray[candidateID].tochokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                    if indexID != -1, let k = savedArray[indexID].nicchokuFuka, let _ = k.range(of: candidateString){
                        isChangable[i] = false
                    }
                }//if indexType == .tochoku, candidateType == .nicchoku
                if indexType == .nicchoku, candidateType == .nicchoku{
                    isChangable[i] = true
                    if candidateID != -1, let k = savedArray[candidateID].nicchokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                    if indexID != -1, let k = savedArray[indexID].nicchokuFuka, let _ = k.range(of: candidateString){
                        isChangable[i] = false
                    }
                }//if indexType == .nicchoku, candidateType == .nicchoku
        }//for i in 0 ..< b.count
        case 2://isFixed:false
            isFixed[indexPath.row] = true
            isChangable = [Bool](repeating: false, count: b.count)
        case 3://selector:0, isChangable:true
            var localComponents = DateComponents()
            localComponents.year = thisClassComponents.year
            localComponents.month = thisClassComponents.month
            localComponents.day = b[anIndex].aDay + dayInterval
            let originalDay = cal.date(from: localComponents)
            let originalPerson = b[anIndex].name
            let originalType = b[anIndex].type.rawValue
            let originalYscore = b[anIndex].yScore
            let changePerson = b[indexPath.row].name
            localComponents.day = b[indexPath.row].aDay + dayInterval
            let changeDay = cal.date(from: localComponents)
            let changeType = b[indexPath.row].type.rawValue
            let changeYscore = b[indexPath.row].yScore
            let hinichiFormatter = DateFormatter()
            hinichiFormatter.locale = Locale(identifier: "ja_JP")
            hinichiFormatter.dateFormat = "M月d日"
            let originalHinichi = hinichiFormatter.string(from: originalDay!)
            let changeHinichi = hinichiFormatter.string(from: changeDay!)
            let titleString = "交換"
            let messageString = "\(originalHinichi) \(originalPerson)先生の\(originalType)\nと\n\(changeHinichi) \(changePerson)先生の\(changeType)を\n交換しますか？"
            let alert: UIAlertController = UIAlertController(title:titleString,
                                                             message: messageString,
                                                             preferredStyle: UIAlertController.Style.alert)
            let okAction: UIAlertAction = UIAlertAction(title: "交換",
                                                        style: UIAlertAction.Style.default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            self.b[self.anIndex].name = changePerson
                                                            self.b[self.anIndex].yScore = changeYscore
                                                            self.b[indexPath.row].name = originalPerson
                                                            self.b[indexPath.row].yScore = originalYscore
                                                            self.isFixed[self.anIndex] = true
                                                            self.isChangable = [Bool](repeating: false, count: self.b.count)
                                                            self.hozonDataRevision()
                                                            tableView.reloadData()
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル",
                                                            style: UIAlertAction.Style.cancel,
                                                            handler:{
                                                                (action:UIAlertAction!) -> Void in
            })//let cancelAction: UIAlertAction = UIAlertAction
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        case 4://selector:1, isFixed:true, isChangable:false
            isFixed = [Bool](repeating: true, count: b.count)
            isChangable = [Bool](repeating: false, count: b.count)
            isFixed[indexPath.row] = false
            for i in 0 ..< b.count{
                if i == indexPath.row{
                    continue
                }
                let candidateDay = b[i].aDay + dayInterval
                let candidateType = b[i].type
                let candidateID = b[i].yScore
                let candidateName = b[i].name
                thisClassComponents.day = candidateDay
                if indexName == candidateName{
                    continue
                }
                if indexType == .yushin, candidateType == .yushin{
                    isChangable[i] = true
                    if candidateID != -1, let k = savedArray[candidateID].yushinFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                }//if indexType == .yushin, candidateType == .yushin
                if indexType == .tochoku, candidateType == .tochoku{
                    isChangable[i] = true
                    if candidateID != -1, let k = savedArray[candidateID].tochokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                }//if indexType == .tochoku, candidateType == .tochoku
                if indexType == .nicchoku, candidateType == .tochoku{
                    isChangable[i] = true
                    if candidateID != -1, let k = savedArray[candidateID].nicchokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                }//if indexType == .nicchoku, candidateType == .tochoku
                if indexType == .tochoku, candidateType == .nicchoku{
                    isChangable[i] = true
                    if candidateID != -1, let k = savedArray[candidateID].tochokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                }//if indexType == .tochoku, candidateType == .nicchoku
                if indexType == .nicchoku, candidateType == .nicchoku{
                    isChangable[i] = true
                    if candidateID != -1, let k = savedArray[candidateID].nicchokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                }//if indexType == .nicchoku, candidateType == .nicchoku
        }//for i in 0 ..< b.count
        case 5://selector:1, isChangable:true
            let originalPerson = b[anIndex].name
            let originalDay = b[anIndex].aDay + dayInterval
            let originalType = b[anIndex].type.rawValue
            let changePerson = b[indexPath.row].name
            let changeYscore = b[indexPath.row].yScore
            let changeName = b[indexPath.row].name
            let titleString = "委譲"
            let messageString = "\(originalDay)日:\(originalPerson)先生の\(originalType)\nを\n\(changePerson)先生に\n委譲しますか？"
            let alert: UIAlertController = UIAlertController(title:titleString,
                                                             message: messageString,
                                                             preferredStyle: UIAlertController.Style.alert)
            let okAction: UIAlertAction = UIAlertAction(title: "委譲",
                                                        style: UIAlertAction.Style.default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            self.b[self.anIndex].name = changeName
                                                            self.b[self.anIndex].yScore = changeYscore
                                                            self.isFixed[self.anIndex] = true
                                                            self.isChangable = [Bool](repeating: false, count: self.b.count)
                                                            self.hozonDataRevision()
                                                            tableView.reloadData()
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル",
                                                            style: UIAlertAction.Style.cancel,
                                                            handler:{
                                                                (action:UIAlertAction!) -> Void in
            })//let cancelAction: UIAlertAction = UIAlertAction
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        default:
            break
        }//switch myFlag
        tableView.reloadData()
    }//func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)

}
