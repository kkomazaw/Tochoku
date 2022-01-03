//
//  CalendarLinkViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/12/09.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import EventKit

class CalendarLinkViewController: UIViewController,UIPickerViewDelegate {
    
    var thisClassComponents = DateComponents()
    var dayInterval = 0
    var nameArray = [String]()
    typealias DayTypeName = (day: Date, type: TochokuType, name: String)
    var dayTypeNames = [DayTypeName]()
    var selectedDayTypeNames = [DayTypeName]()
    let localFormatter = DateFormatter()
    var selectedName = ""
    let eventStore:EKEventStore = EKEventStore()
    
    @IBOutlet var myPicker:UIPickerView!
    @IBOutlet var myTextView:UITextView!
    @IBOutlet var mySegments:UISegmentedControl!
    @IBOutlet var hozonButton:UIBarButtonItem!
    @IBOutlet var myToolBar:UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        //iPhone X 以降で、以下のコードが実行されます
        if height > 800.0 && height < 1000.0 {
            myToolBar.frame = CGRect(x: 0, y: height * 0.92, width: width, height: height * 0.055)
        }//if height > 800.0 && height < 1000.0
        if EKEventStore.authorizationStatus(for: .event) == .notDetermined{
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if granted && error == nil {
                    print("granted")
                }
                else{
                    print("not granted")
                }
            })//eventStore.requestAccess
        }//if EKEventStore.authorizationStatus(for: .event) == .notDetermined
        print(tochokuString)
        localFormatter.dateFormat = "yyyy年M月d日 (EE)"
        let enterSeparatedArray = tochokuString.components(separatedBy: "\n")
        let yearMonth = enterSeparatedArray.filter{$0.contains("年") && $0.contains("月")}
        let dateArr = yearMonth[0].components(separatedBy: "年")
        let month = dateArr[1].components(separatedBy: "月")[0]
        let tochokuContainsArray = enterSeparatedArray.filter{$0.contains("夕診") || $0.contains("日直") || $0.contains("当直")}.filter{$0.contains("(") && $0.contains(")")}
        let day = tochokuContainsArray[0].components(separatedBy: "日")[0]
        thisClassComponents.year = Int(dateArr[0])
        thisClassComponents.month = Int(month)
        thisClassComponents.day = Int(day)
        var localComponents = DateComponents()
        localComponents.year = Int(dateArr[0])
        localComponents.month = Int(month)
        localComponents.day = Int(day)
        for i in 0 ..< tochokuContainsArray.count{
            localComponents.day = thisClassComponents.day! + i
            let day = cal.date(from: localComponents)
            var subArr = [String]()
            if tochokuContainsArray[i].contains("\t"){
                subArr = tochokuContainsArray[i].components(separatedBy: "\t")
            }
            else{
                subArr = tochokuContainsArray[i].components(separatedBy: " ").filter{$0 != " " && $0 != ""}
            }
            if let index = subArr.firstIndex(where: {$0.contains("夕診")}){
                dayTypeNames.append((day!, .yushin, subArr[index + 1]))
            }
            if let index = subArr.firstIndex(where: {$0.contains("当直")}){
                dayTypeNames.append((day!, .tochoku, subArr[index + 1]))
            }
            if let index = subArr.firstIndex(where: {$0.contains("日直")}){
                let subsubArr = subArr[index + 1].components(separatedBy: "/")
                dayTypeNames.append((day!, .nicchoku, subsubArr[0]))
                dayTypeNames.append((day!, .tochoku, subsubArr[1]))
            }
        }//for i in 0 ..< tochokuContainsArray.count
        print(dayTypeNames)
        for i in 0 ..< dayTypeNames.count{
            if !nameArray.contains(dayTypeNames[i].name){
                nameArray.append(dayTypeNames[i].name)
            }
        }//for i in 0 ..< dayTypeNames.count
        print(nameArray)
        selectedName = nameArray[0]
        displaySelectedTochoku(name: selectedName)
    }//override func viewDidLoad()
    
    @objc func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int {
        return 1
    }
    
    @objc func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        return nameArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedName = nameArray[row]
        displaySelectedTochoku(name: selectedName)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return nameArray[row]
    }
    
    func displaySelectedTochoku(name:String){
        if nameArray.count == 0 { return }
        selectedDayTypeNames = dayTypeNames.filter{$0.name == name}
        var hozonText = ""
        var nameString = ""
        if mySegments.selectedSegmentIndex == 0{
            nameString = name
        }
        for i in 0 ..< selectedDayTypeNames.count{
            hozonText += "\(localFormatter.string(from: selectedDayTypeNames[i].day))\t\(nameString)\t\(selectedDayTypeNames[i].type.rawValue)\n"
        }
        myTextView.text = hozonText
    }//func displaySelectedTochoku(name:String)
    
    @IBAction func myActionSegmentChanged(){
        displaySelectedTochoku(name: selectedName)
    }
    
    @IBAction func myActionHozon(){
        if EKEventStore.authorizationStatus(for: .event) == .authorized{
            var isSaved = true
            var nameString = ""
            if mySegments.selectedSegmentIndex == 0{
                nameString = selectedName
            }
            for i in 0 ..< selectedDayTypeNames.count{
                let event = EKEvent(eventStore: eventStore)
                event.title = "\(nameString) \(selectedDayTypeNames[i].type.rawValue)"
                event.startDate = selectedDayTypeNames[i].day
                event.endDate = selectedDayTypeNames[i].day
                event.isAllDay = true
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                    isSaved = true
                }
                catch {
                    isSaved = false
                }
            }//for i in 0 ..< selectedDayTypeNames.count
            if isSaved{
                let alert = UIAlertController(title: "保存完了", message: "カレンダーに保存されました。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }//if EKEventStore.authorizationStatus(for: .event) == .authorized
        else{
            let alert = UIAlertController(title: "カレンダーアクセス", message: "カレンダーに保存するためには、\n設定>\nプライバシー>\nカレンダー\nでアクセスを許可して下さい。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }//else
    }//@IBAction func myActionHozon()
    
}//class CalendarLinkViewController: UIViewController
