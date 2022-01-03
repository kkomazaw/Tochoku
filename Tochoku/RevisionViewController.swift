//
//  RevisionViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/07/22.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class RevisionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var savedArray:[TochokuData] = []
    var isFixed:[Bool] = []
    var isChangable:[Bool] = []
    var anIndex = 0
    var b = Array<YusenScore>()
    var bufferIndex = 0
    var dayInterval = 0
    
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
        b = buffer[bufferCount - 1].yusenTuple
        let startDay = buffer[bufferCount - 1].firstDayDate
        dayInterval = (Calendar.current.dateComponents([.day], from: selectedDay!, to: startDay)).day!
        if let i = bufferScores.firstIndex(where: {$0.month == monthString2 && $0.serial == bufferCount - 1}){
            bufferIndex = i
        }
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
        isFixed = [Bool](repeating: true, count: b.count)
        isChangable = [Bool](repeating: false, count: b.count)
        self.navigationItem.title = "移動者選択"

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var c = 0
        if bufferCount >= 1{
            c = b.count
        }
        return c
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Name", for: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        let day = b[indexPath.row].aDay + dayInterval
        let type = b[indexPath.row].type
        let name = savedArray[b[indexPath.row].yScore].name
        selectedComponents.day = day
        let selectedDay = cal.date(from: selectedComponents)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "M月d日 (EE)"
        let dayString = selectedDateFormatter.string(from: selectedDay!)
        selectedDateFormatter.dateFormat = "yyyy年M月d日"
        let kibobiString = selectedDateFormatter.string(from: selectedDay!)
        cell.textLabel!.text = "\(dayString) \(type.rawValue) \(name ?? "")"
        switch type {
        case .yushin:
            if let l = savedArray[b[indexPath.row].yScore].yushinKibo, let _ = l.range(of: kibobiString){
                cell.textLabel!.text = "\(dayString) \(type.rawValue) \(name ?? "") (希望)"
            }
        case .nicchoku:
            if let l = savedArray[b[indexPath.row].yScore].nicchokuKibo, let _ = l.range(of: kibobiString){
                cell.textLabel!.text = "\(dayString) \(type.rawValue) \(name ?? "") (希望)"
            }
        case .tochoku:
            if let l = savedArray[b[indexPath.row].yScore].tochokuKibo, let _ = l.range(of: kibobiString){
                cell.textLabel!.text = "\(dayString) \(type.rawValue) \(name ?? "") (希望)"
            }
        }//switch type
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
    }
    //let b = bufferScores[bufferCount - 1]
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexDay = b[indexPath.row].aDay + dayInterval
        let indexType = b[indexPath.row].type
        let indexID = b[indexPath.row].yScore
        selectedComponents.day = indexDay
        let selectedDay = cal.date(from: selectedComponents)
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
                selectedComponents.day = candidateDay
                let cDay = cal.date(from: selectedComponents)
                let candidateString = selectedDateFormatter.string(from: cDay!)
                if indexID == candidateID{
                    continue
                }
                if indexType == .yushin, candidateType == .yushin{
                    isChangable[i] = true
                    if let k = savedArray[candidateID].yushinFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                    if let k = savedArray[indexID].yushinFuka, let _ = k.range(of: candidateString){
                        isChangable[i] = false
                    }
                }//if indexType == .yushin, candidateType == .yushin
                if indexType == .tochoku, candidateType == .tochoku{
                    isChangable[i] = true
                    if let k = savedArray[candidateID].tochokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                    if let k = savedArray[indexID].tochokuFuka, let _ = k.range(of: candidateString){
                        isChangable[i] = false
                    }
                }//if indexType == .tochoku, candidateType == .tochoku
                if indexType == .nicchoku, candidateType == .tochoku{
                    isChangable[i] = true
                    if let k = savedArray[candidateID].nicchokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                    if let k = savedArray[indexID].tochokuFuka, let _ = k.range(of: candidateString){
                        isChangable[i] = false
                    }
                }//if indexType == .nicchoku, candidateType == .tochoku
                if indexType == .tochoku, candidateType == .nicchoku{
                    isChangable[i] = true
                    if let k = savedArray[candidateID].tochokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                    if let k = savedArray[indexID].nicchokuFuka, let _ = k.range(of: candidateString){
                        isChangable[i] = false
                    }
                }//if indexType == .tochoku, candidateType == .nicchoku
                if indexType == .nicchoku, candidateType == .nicchoku{
                    isChangable[i] = true
                    if let k = savedArray[candidateID].nicchokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                    if let k = savedArray[indexID].nicchokuFuka, let _ = k.range(of: candidateString){
                        isChangable[i] = false
                    }
                }//if indexType == .nicchoku, candidateType == .nicchoku
        }//for i in 0 ..< b.count
        case 2://isFixed:false
            isFixed[indexPath.row] = true
            isChangable = [Bool](repeating: false, count: b.count)
        case 3://selector:0, isChangable:true
            var localComponents = DateComponents()
            localComponents.year = components.year
            localComponents.month = components.month
            localComponents.day = b[anIndex].aDay + dayInterval
            let originalDay = cal.date(from: localComponents)
            let originalPerson = savedArray[b[anIndex].yScore].name
            let originalID = b[anIndex].yScore
            
            let originalType = b[anIndex].type.rawValue
            let changePerson = savedArray[b[indexPath.row].yScore].name
            let changeID = b[indexPath.row].yScore
            localComponents.day = b[indexPath.row].aDay + dayInterval
            let changeDay = cal.date(from: localComponents)
            let changeType = b[indexPath.row].type.rawValue
            let hinichiFormatter = DateFormatter()
            hinichiFormatter.locale = Locale(identifier: "ja_JP")
            hinichiFormatter.dateFormat = "M月d日"
            let originalHinichi = hinichiFormatter.string(from: originalDay!)
            let changeHinichi = hinichiFormatter.string(from: changeDay!)
            let titleString = "交換"
            let messageString = "\(originalHinichi) \(originalPerson ?? "")先生の\(originalType)\nと\n\(changeHinichi) \(changePerson ?? "")先生の\(changeType)を\n交換しますか？"
            let alert: UIAlertController = UIAlertController(title:titleString,
                                                             message: messageString,
                                                             preferredStyle: UIAlertController.Style.alert)
            let okAction: UIAlertAction = UIAlertAction(title: "交換",
                                                        style: UIAlertAction.Style.default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                        bufferScores[self.bufferIndex].yusenTuple[self.anIndex].yScore = changeID
                                                            bufferScores[self.bufferIndex].yusenTuple[indexPath.row].yScore = originalID
                                                            self.isFixed[self.anIndex] = true
                                                            self.isChangable = [Bool](repeating: false, count: self.b.count)
                                                            self.b = bufferScores[self.bufferIndex].yusenTuple
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
                selectedComponents.day = candidateDay
                if indexID == candidateID{
                    continue
                }
                if indexType == .yushin, candidateType == .yushin{
                    isChangable[i] = true
                    if let k = savedArray[candidateID].yushinFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                }//if indexType == .yushin, candidateType == .yushin
                if indexType == .tochoku, candidateType == .tochoku{
                    isChangable[i] = true
                    if let k = savedArray[candidateID].tochokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                }//if indexType == .tochoku, candidateType == .tochoku
                if indexType == .nicchoku, candidateType == .tochoku{
                    isChangable[i] = true
                    if let k = savedArray[candidateID].nicchokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                }//if indexType == .nicchoku, candidateType == .tochoku
                if indexType == .tochoku, candidateType == .nicchoku{
                    isChangable[i] = true
                    if let k = savedArray[candidateID].tochokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                }//if indexType == .tochoku, candidateType == .nicchoku
                if indexType == .nicchoku, candidateType == .nicchoku{
                    isChangable[i] = true
                    if let k = savedArray[candidateID].nicchokuFuka, let _ = k.range(of: indexString){
                        isChangable[i] = false
                    }
                }//if indexType == .nicchoku, candidateType == .nicchoku
        }//for i in 0 ..< b.count
        case 5://selector:1, isChangable:true
            let originalPerson = savedArray[b[anIndex].yScore].name
            var localComponents = DateComponents()
            localComponents.year = components.year
            localComponents.month = components.month
            localComponents.day = b[anIndex].aDay + dayInterval
            let originalDay = cal.date(from: localComponents)
            let hinichiFormatter = DateFormatter()
            hinichiFormatter.locale = Locale(identifier: "ja_JP")
            hinichiFormatter.dateFormat = "M月d日"
            let originalHinichi = hinichiFormatter.string(from: originalDay!)
            let originalType = b[anIndex].type.rawValue
            let changePerson = savedArray[b[indexPath.row].yScore].name
            let changeID = b[indexPath.row].yScore
            let titleString = "委譲"
            let messageString = "\(originalHinichi) \(originalPerson ?? "")先生の\(originalType)\nを\n\(changePerson ?? "")先生に\n委譲しますか？"
            let alert: UIAlertController = UIAlertController(title:titleString,
                                                             message: messageString,
                                                             preferredStyle: UIAlertController.Style.alert)
            let okAction: UIAlertAction = UIAlertAction(title: "委譲",
                                                        style: UIAlertAction.Style.default,
                                                        handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            bufferScores[self.bufferIndex].yusenTuple[self.anIndex].yScore = changeID
                                                            self.isFixed[self.anIndex] = true
                                                            self.isChangable = [Bool](repeating: false, count: self.b.count)
                                                            self.b = bufferScores[self.bufferIndex].yusenTuple
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
