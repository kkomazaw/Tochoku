//
//  YNNAFukabiViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/10/24.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class YNNAFukabiViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    enum DayType{
        case heijitsu
        case doyo
        case kyujitsu
    }
    
    var kyujitsuHeijitsuArray:Array<DayType> = []
    
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet var zengetsuButton:UIButton!
    @IBOutlet var jigetsuButton:UIButton!
    @IBOutlet var myCollectionView:UICollectionView!
    @IBOutlet var tochokuSegment:UISegmentedControl!
    @IBOutlet var ableOrNot:UISegmentedControl!
    @IBOutlet var tochokukaiField:UITextField!
    @IBOutlet var okButton:UIButton!
    @IBOutlet var sakuseishaniOkuru:UIButton!
    
    var weekdayAdding = 0
    var tochokukai = Int()
    var tochokukibobi = String()
    var nicchokukibobi = String()
    var tochokufukabi = String()
    var nicchokufukabi = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jujishaDefaults.register(defaults: ["tochokukai":-1, "yushinkai":-1, "tochokukibobi":"", "yushinkibobi":"", "nicchokukibobi":"","tochokufukabi":"","yushinfukabi":"", "nicchokufukabi":""])
        tochokukai = jujishaDefaults.integer(forKey: "tochokukai")
        tochokukibobi = jujishaDefaults.string(forKey: "tochokukibobi")!
        nicchokukibobi = jujishaDefaults.string(forKey: "nicchokukibobi")!
        tochokufukabi = jujishaDefaults.string(forKey: "tochokufukabi")!
        nicchokufukabi = jujishaDefaults.string(forKey: "nicchokufukabi")!
        if tochokukai >= 0{
            tochokukaiField.text = "\(tochokukai)"
        }
        else{
            tochokukaiField.text = ""
        }
        kyujitsuHeijitsuArray = [DayType](repeating: .heijitsu, count: 31)
        tochokuSegment.selectedSegmentIndex = 3
        cal.locale = Locale(identifier: "ja")
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy年M月"
        components.year = cal.component(.year, from: now)
        components.month = cal.component(.month, from: now) + 1
        components.day = 1
        calculation()
    }
    
    func calculation(){
        let firstDayOfMonth = cal.date(from: components)
        dateLabel.text = dateFormatter.string(from: firstDayOfMonth!)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 37
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellYNNA", for: indexPath) as! YNNASubCalendarCollectionViewCell
        let firstDayOfMonth = cal.date(from: components)
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth!)
        weekdayAdding = 2 - firstWeekday
        
        let daysCountInMonth = cal.range(of: .day, in: .month, for: firstDayOfMonth!)?.count
        if (indexPath.row + weekdayAdding) >= 1 && (indexPath.row + weekdayAdding) <= daysCountInMonth! {
            cell.backgroundColor =  #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
            selectedComponents.year = components.year
            selectedComponents.month = components.month
            selectedComponents.day = indexPath.row + weekdayAdding
            let selectedDay = cal.date(from: selectedComponents)
            let selectedDateFormatter = DateFormatter()
            selectedDateFormatter.dateFormat = "yyyy年M月d日"
            let dateString = selectedDateFormatter.string(from: selectedDay!)
            var addString = ""
            if let _ = nicchokufukabi.range(of: dateString){
                addString += "日×"
            }
            if let _ = nicchokukibobi.range(of: dateString){
                addString += "日◎"
            }
            if let _ = tochokufukabi.range(of: dateString){
                addString += "当×"
            }
            if let _ = tochokukibobi.range(of: dateString){
                addString += "当◎"
            }
            if addString == ""{
                cell.Label.text = "\(indexPath.row + weekdayAdding)"
            }
            else{
                cell.Label.text = "\(indexPath.row + weekdayAdding)\n" + addString
            }
            kyujitsuHantei()
            switch kyujitsuHeijitsuArray[indexPath.row + weekdayAdding - 1]{
            case .heijitsu:
                cell.Label.textColor = UIColor.black
            case .kyujitsu:
                cell.Label.textColor = UIColor.red
            case .doyo:
                cell.Label.textColor = UIColor.blue
            }//switch kyujitsuHeijitsuArray[indexPath.row + weekdayAdding - 1]
        }
        else{
            if #available(iOS 13.0, *) {
                cell.backgroundColor = UIColor.systemBackground
            } else {
                cell.backgroundColor = UIColor.white
            }
            cell.Label.text = ""
        }
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        kyujitsuHantei()
    }
    
    func kyujitsuHantei(){
        let firstDayOfMonth = cal.date(from: components)
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth!)
        weekdayAdding = 2 - firstWeekday
        let daysCountInMonth = cal.range(of: .day, in: .month, for: firstDayOfMonth!)?.count
        for i in 0 ..< 37{
            if (i + weekdayAdding) >= 1 && (i + weekdayAdding) <= daysCountInMonth!{
                selectedComponents.year = components.year
                selectedComponents.month = components.month
                selectedComponents.day = i + weekdayAdding
                let selectedDay = cal.date(from: selectedComponents)
                let selectedDateFormatter = DateFormatter()
                selectedDateFormatter.dateFormat = "yyyy年M月d日"
                let dateString = selectedDateFormatter.string(from: selectedDay!)
                //1日(ついたち)は、kyujitsuHeijitsuArray[0]となります。
                if i % 7 == 0{
                    kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .kyujitsu
                }
                else if i % 7 == 6{
                    kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .doyo
                }
                else{
                    kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .heijitsu
                }
                if let _ = holiday.range(of: dateString){
                    kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .kyujitsu
                }
            }//if (i + weekdayAdding) >= 1 && (i + weekdayAdding) <= daysCountInMonth
        }//for i in 0 ..< 37
    }//func kyujitsuHantei()
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedComponents.year = components.year
        selectedComponents.month = components.month
        selectedComponents.day = indexPath.row + weekdayAdding
        let selectedDay = cal.date(from: selectedComponents)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.dateFormat = "yyyy年M月d日"
        if dateLabel.text == dateFormatter.string(from: selectedDay!){
            let dateString = selectedDateFormatter.string(from: selectedDay!) + "\n"
            let cell = collectionView.cellForItem(at: indexPath) as! YNNASubCalendarCollectionViewCell
            switch ableOrNot.selectedSegmentIndex{
            case 0://不可
                switch tochokuSegment.selectedSegmentIndex{
                case 0://clear
                    cell.Label.text = "\(indexPath.row + weekdayAdding)"
                    clearSavedData(dateString)
                case 1://日直
                    guard kyujitsuHeijitsuArray[indexPath.row + weekdayAdding - 1] == .kyujitsu else {return}
                    if let range = cell.Label.text!.range(of: "日◎"){
                        cell.Label.text?.replaceSubrange(range, with: "日×")
                        let range2 = nicchokukibobi.range(of: dateString)
                        nicchokukibobi.replaceSubrange(range2!, with: "")
                        nicchokufukabi += dateString
                    }
                    else{
                        if let range = cell.Label.text!.range(of: "日×"){
                            cell.Label.text?.replaceSubrange(range, with: "")
                            let range2 = nicchokufukabi.range(of: dateString)
                            nicchokufukabi.replaceSubrange(range2!, with: "")
                        }
                        else{
                            if let range = cell.Label.text!.range(of: "当"){
                                cell.Label.text?.replaceSubrange(range, with: "日×当")
                                nicchokufukabi += dateString
                            }
                            else{
                                if let _ = cell.Label.text!.range(of: "\n"){
                                    cell.Label.text = cell.Label.text! + "日×"
                                }
                                else{
                                    cell.Label.text = cell.Label.text! + "\n日×"
                                }
                                nicchokufukabi += dateString
                            }
                        }
                    }
                case 2://当直
                    if let range = cell.Label.text!.range(of: "当◎"){
                        cell.Label.text?.replaceSubrange(range, with: "当×")
                        let range2 = tochokukibobi.range(of: dateString)
                        tochokukibobi.replaceSubrange(range2!, with: "")
                        tochokufukabi += dateString
                    }
                    else{
                        if let range = cell.Label.text!.range(of: "当×"){
                            cell.Label.text?.replaceSubrange(range, with: "")
                            let range2 = tochokufukabi.range(of: dateString)
                            tochokufukabi.replaceSubrange(range2!, with: "")
                        }
                        else{
                            if let _ = cell.Label.text!.range(of: "\n"){
                                cell.Label.text = cell.Label.text! + "当×"
                            }
                            else{
                                cell.Label.text = cell.Label.text! + "\n当×"
                            }
                            tochokufukabi += dateString
                        }
                    }
                default:
                    break
                }
            case 1://希望
                switch tochokuSegment.selectedSegmentIndex{
                case 0://clear
                    cell.Label.text = "\(indexPath.row + weekdayAdding)"
                    clearSavedData(dateString)
                case 1://日直
                    guard kyujitsuHeijitsuArray[indexPath.row + weekdayAdding - 1] == .kyujitsu else {return}
                    if let range = cell.Label.text!.range(of: "日×"){
                        cell.Label.text?.replaceSubrange(range, with: "日◎")
                        let range2 = nicchokufukabi.range(of: dateString)
                        nicchokufukabi.replaceSubrange(range2!, with: "")
                        nicchokukibobi += dateString
                    }
                    else{
                        if let range = cell.Label.text!.range(of: "日◎"){
                            cell.Label.text?.replaceSubrange(range, with: "")
                            let range2 = nicchokukibobi.range(of: dateString)
                            nicchokukibobi.replaceSubrange(range2!, with: "")
                        }
                        else{
                            if let range = cell.Label.text!.range(of: "当"){
                                cell.Label.text?.replaceSubrange(range, with: "日◎当")
                                nicchokukibobi += dateString
                            }
                            else{
                                if let _ = cell.Label.text!.range(of: "\n"){
                                    cell.Label.text = cell.Label.text! + "日◎"
                                }
                                else{
                                    cell.Label.text = cell.Label.text! + "\n日◎"
                                }
                                nicchokukibobi += dateString
                            }
                        }
                    }
                case 2://当直
                    if let range = cell.Label.text!.range(of: "当×"){
                        cell.Label.text?.replaceSubrange(range, with: "当◎")
                        let range2 = tochokufukabi.range(of: dateString)
                        tochokufukabi.replaceSubrange(range2!, with: "")
                        tochokukibobi += dateString
                    }
                    else{
                        if let range = cell.Label.text!.range(of: "当◎"){
                            cell.Label.text?.replaceSubrange(range, with: "")
                            let range2 = tochokukibobi.range(of: dateString)
                            tochokukibobi.replaceSubrange(range2!, with: "")
                        }
                        else{
                            if let _ = cell.Label.text!.range(of: "\n"){
                                cell.Label.text = cell.Label.text! + "当◎"
                            }
                            else{
                                cell.Label.text = cell.Label.text! + "\n当◎"
                            }
                            tochokukibobi += dateString
                        }
                    }
                default:
                    break
                }
            default:
                break
            }
            if cell.Label.text == "\(indexPath.row + weekdayAdding)\n"{
                cell.Label.text = "\(indexPath.row + weekdayAdding)"
            }
            setUserDefaults()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let myBoundSize: CGFloat = UIScreen.main.bounds.size.width
        let cellSize : CGFloat = myBoundSize / 7.5
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    @IBAction func myActionZengetsu(){
        components.month = components.month! - 1
        calculation()
        myCollectionView.reloadData()
        kyujitsuHantei()
    }
    
    @IBAction func myActionJigetsu(){
        components.month = components.month! + 1
        calculation()
        myCollectionView.reloadData()
        kyujitsuHantei()
    }
    
    @IBAction func myActionOK(){
        view.endEditing(true)
        if let i = Int(tochokukaiField.text!){
            tochokukai = i
        }//if let i = Int(tochokukaiField.text!)
        else{
            tochokukai = -1
        }
        jujishaDefaults.set(tochokukai, forKey: "tochokukai")
    }//@IBAction func myActionOK()
    
    func setUserDefaults(){
        jujishaDefaults.set(nicchokufukabi, forKey: "nicchokufukabi")
        jujishaDefaults.set(tochokufukabi, forKey: "tochokufukabi")
        jujishaDefaults.set(nicchokukibobi, forKey: "nicchokukibobi")
        jujishaDefaults.set(tochokukibobi, forKey: "tochokukibobi")
    }//func setUserDefaults()
    
    func clearSavedData(_ dateString:String){
        if let range = nicchokufukabi.range(of: dateString){
            nicchokufukabi.replaceSubrange(range, with: "")
        }
        if let range = tochokufukabi.range(of: dateString){
            tochokufukabi.replaceSubrange(range, with: "")
        }
        if let range = nicchokukibobi.range(of: dateString){
            nicchokukibobi.replaceSubrange(range, with: "")
        }
        if let range = tochokukibobi.range(of: dateString){
            tochokukibobi.replaceSubrange(range, with: "")
        }
        setUserDefaults()
    }//func clearSavedData(dateString:String)
    
    @IBAction func myActionOkuru(){
        selectedComponents.year = components.year
        selectedComponents.month = components.month
        selectedComponents.day = 1
        let selectedDay = cal.date(from: selectedComponents)
        let thisMonth = dateFormatter.string(from: selectedDay!)
        let nicchokufukaArr = nicchokufukabi.components(separatedBy: "\n")
        let thisMonthNicchokuFukaArr = nicchokufukaArr.filter{$0 .contains(thisMonth)}
        var thisMonthNicchokuFukaString = "日直不可日\n"
        for i in thisMonthNicchokuFukaArr{
            thisMonthNicchokuFukaString += i + "\n"
        }
        if thisMonthNicchokuFukaArr.count == 0{
            thisMonthNicchokuFukaString += "なし\n"
        }
        let tochokufukaArr = tochokufukabi.components(separatedBy: "\n")
        let thisMonthTochokuFukaArr = tochokufukaArr.filter{$0 .contains(thisMonth)}
        var thisMonthTochokuFukaString = "当直不可日\n"
        for i in thisMonthTochokuFukaArr{
            thisMonthTochokuFukaString += i + "\n"
        }
        if thisMonthTochokuFukaArr.count == 0{
            thisMonthTochokuFukaString += "なし\n"
        }
        let nicchokukiboArr = nicchokukibobi.components(separatedBy: "\n")
        let thisMonthNicchokuKiboArr = nicchokukiboArr.filter{$0 .contains(thisMonth)}
        var thisMonthNicchokuKiboString = "日直希望日\n"
        for i in thisMonthNicchokuKiboArr{
            thisMonthNicchokuKiboString += i + "\n"
        }
        if thisMonthNicchokuKiboArr.count == 0{
            thisMonthNicchokuKiboString += "なし\n"
        }
        let tochokukiboArr = tochokukibobi.components(separatedBy: "\n")
        let thisMonthTochokuKiboArr = tochokukiboArr.filter{$0 .contains(thisMonth)}
        var thisMonthTochokuKiboString = "当直希望日\n"
        for i in thisMonthTochokuKiboArr{
            thisMonthTochokuKiboString += i + "\n"
        }
        if thisMonthTochokuKiboArr.count == 0{
            thisMonthTochokuKiboString += "なし\n"
        }
        var tochokukaiString = "当直回数\n指定なし\n"
        if let _ = Int(tochokukaiField.text!), tochokukai >= 0{
            tochokukaiString = "当直回数\n\(tochokukai)\n"
        }
        let okuruString = thisMonth + "\n" + tochokukaiString  + thisMonthNicchokuFukaString + thisMonthTochokuFukaString + thisMonthNicchokuKiboString + thisMonthTochokuKiboString
            print (okuruString)
        let activityItems = [okuruString] as [Any]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        let excludedActivityTypes = [
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.print
        ]
        
        activityVC.excludedActivityTypes = excludedActivityTypes
        
        self.present(activityVC, animated: true, completion: nil)
    }//@IBAction func myActionOkuru()
}
