//
//  DNSakuseiViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/10/29.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class DNSakuseiViewController: UIViewController, UIPickerViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var savedArray:[TochokuData] = []
    var isRevisedArray:Array<Bool> = []
    var selectedRow = 0
    
    enum DayType{
        case heijitsu
        case doyo
        case kyujitsu
    }
    
    typealias KyujitsuTuple = (aDay:Int, dayString:String, dayDate:Date, type:DayType)
    
    var kyujitsuHeijitsuArray:Array<DayType> = []
    var kyujitsuTupleArray:Array<KyujitsuTuple> = []
    var filteredTupleArray:Array<KyujitsuTuple> = []
    
    @IBOutlet var myPicker:UIPickerView!
    @IBOutlet var NyuryokuKanryo:UIButton!
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet var zengetsuButton:UIButton!
    @IBOutlet var jigetsuButton:UIButton!
    @IBOutlet var myCollectionView:UICollectionView!
    @IBOutlet var tochokuSegment:UISegmentedControl!
    @IBOutlet var ableOrNot:UISegmentedControl!
    @IBOutlet var kisakuButton:UIButton!
    
    var weekdayAdding = 0
    typealias TestScore = (id: Int, score: Int)
    typealias DayInterval = (day: Int, interval: Double)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kyujitsuHeijitsuArray = [DayType](repeating: .heijitsu, count: 31)
        tochokuSegment.selectedSegmentIndex = 1
        cal.locale = Locale(identifier: "ja")
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy年M月"
        components.year = cal.component(.year, from: now)
        components.month = cal.component(.month, from: now) + 1
        components.day = 1
        calculation()
        selectedPerson = ""
        let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            
            let sortDescripter = NSSortDescriptor(key: "torokubi", ascending: true)
            let fetchRequest: NSFetchRequest<TochokuData> = TochokuData.fetchRequest()
            fetchRequest.sortDescriptors = [sortDescripter]
            savedArray = try myContext.fetch(fetchRequest)
            isRevisedArray = [Bool](repeating: false, count: savedArray.count)
        }
        catch {
            print("Fetching Failed.")
        }
        if let i = savedArray[0].name{
            selectedPerson = i
            self.navigationItem.title = i + "当直希望"
        }
    }//override func viewDidLoad()
    
    override func viewDidAppear(_ animated: Bool) {
        kyujitsuHantei()
        kaisuHantei()
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
    
    //weekdayは日曜日が1、土曜日が7になります。
    
    func kyujitsuHantei2(){
        var localComponents = DateComponents()
        //startDayDate:カレンダーの曜日判定を開始する日で通常は1日
        var startDayDate = Date()
        var endDayDate = Date()
        //firstDayDate:当直表の開始日（未指定の場合は1日）
        var firstDayDate = Date()
        var lastDayDate = Date()
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.dateFormat = "yyyy年M月d日"
        //startDayString, endDayStringはClass:KyujitsuHenkoViewで選択された日(global)
        if startDayString == ""{
            startDayDate = cal.date(from: components)!
            firstDayDate = cal.date(from: components)!
        }
        else if let i = selectedDateFormatter.date(from: startDayString){
            startDayDate = i
            firstDayDate = i
        }
        if startDayDate > cal.date(from: components)!{
            startDayDate = cal.date(from: components)!
        }
        let firstDayOfMonth = cal.date(from: components)
        let daysCountInMonth = cal.range(of: .day, in: .month, for: firstDayOfMonth!)?.count
        localComponents.year = components.year
        localComponents.month = components.month
        localComponents.day = daysCountInMonth
        if endDayString == ""{
            endDayDate = cal.date(from: localComponents)!
            lastDayDate = cal.date(from: localComponents)!
        }
        else if let i = selectedDateFormatter.date(from: endDayString){
            endDayDate = i
            lastDayDate = i
        }
        if endDayDate < cal.date(from: localComponents)!{
            endDayDate = cal.date(from: localComponents)!
        }
        let dayInterval:Int = (Calendar.current.dateComponents([.day], from: startDayDate, to: endDayDate)).day!
        kyujitsuTupleArray.removeAll()
        localComponents = cal.dateComponents([.year, .month, .day], from: startDayDate)
        var aDay = 1
        for i in 0 ... dayInterval{
            let selectedDay = cal.date(from: localComponents)!
            let selectedString = selectedDateFormatter.string(from: selectedDay)
            let weekday = cal.component(.weekday, from: selectedDay)
            var dayIndex = -1
            if selectedDay >= firstDayDate && selectedDay <= lastDayDate{
                dayIndex = aDay
            }
            //weekdayは日曜日が1、土曜日が7になります。
            if weekday == 1{
                kyujitsuTupleArray.append((dayIndex, selectedString, selectedDay, .kyujitsu))
                if let _ = nichiyouHeijitsuString.range(of: selectedString){
                    kyujitsuTupleArray[i].type = .heijitsu
                }
            }//if weekday == 1
            if weekday >= 2 && weekday <= 6{
                kyujitsuTupleArray.append((dayIndex, selectedString, selectedDay, .heijitsu))
            }//if weekday >= 2 && weekday <= 6
            if weekday == 7{
                kyujitsuTupleArray.append((dayIndex, selectedString, selectedDay, .doyo))
            }//if weekday == 7
            if let _ = holiday.range(of: selectedString){
                kyujitsuTupleArray[i].type = .kyujitsu
            }//if let _ = holiday.range(of: selectedString)
            aDay = aDay + 1
            localComponents.day = localComponents.day! + 1
        }//for i in 0 ... dayInterval
        filteredTupleArray = kyujitsuTupleArray.filter{$0.aDay != -1}
        print("filteredTupleArray count = \(filteredTupleArray.count)")
    }//func kyujitsuHantei2()
    
    func kaisuHantei(){
        /*   if savedArray.count == 0{
         return
         }//if savedArray.count == 0 */
        let doctorCount = savedArray.count
        let daysCountInMonth = filteredTupleArray.count
        var totalTochokukibo = 0
        for i in 0 ..< doctorCount{
            totalTochokukibo += Int(savedArray[i].tochokukai)
        }
        var totalTochoku = 0
        for i in 0 ..< daysCountInMonth{
            if filteredTupleArray[i].type == .kyujitsu{
                totalTochoku += 1
            }
            else{
                totalTochoku += 1
            }
        }
        if totalTochokukibo != totalTochoku {
            let titleString = "希望回数と実際の回数が異なります。"
            var messageString = ""
            if totalTochokukibo != totalTochoku{
                messageString += "総当直回数 \(totalTochoku)回, 総当直希望 \(totalTochokukibo)回\n"
            }
            let alert: UIAlertController = UIAlertController(title:titleString,message: messageString,preferredStyle: UIAlertController.Style.alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK",style: UIAlertAction.Style.default,handler:{(action:UIAlertAction!) -> Void in
            })
            alert.addAction(okAction)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }//if totalTochokukibo != totalTochoku
    }//func kaisuHantei()
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DNCell", for: indexPath) as! DNCollectionViewCell
        let firstDayOfMonth = cal.date(from: components)
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth!)
        weekdayAdding = 2 - firstWeekday
        
        let daysCountInMonth = cal.range(of: .day, in: .month, for: firstDayOfMonth!)?.count
        if (indexPath.row + weekdayAdding) >= 1 && (indexPath.row + weekdayAdding) <= daysCountInMonth! {
            cell.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
            selectedComponents.year = components.year
            selectedComponents.month = components.month
            selectedComponents.day = indexPath.row + weekdayAdding
            let selectedDay = cal.date(from: selectedComponents)
            let selectedDateFormatter = DateFormatter()
            selectedDateFormatter.dateFormat = "yyyy年M月d日"
            let dateString = selectedDateFormatter.string(from: selectedDay!)
            var addString = ""
            if let i = savedArray[selectedRow].tochokuFuka, let _ = i.range(of: dateString){
                addString += "当×"
            }
            if let i = savedArray[selectedRow].tochokuKibo, let _ = i.range(of: dateString){
                addString += "当◎"
            }
            var shitenShutenString = ""
            if dateString == startDayString{
                shitenShutenString = "始点"
            }
            if dateString == endDayString{
                shitenShutenString = "終点"
            }
            if addString == ""{
                cell.Label.text = "\(indexPath.row + weekdayAdding)" + shitenShutenString
            }
            else{
                cell.Label.text = "\(indexPath.row + weekdayAdding)" + shitenShutenString + "\n" + addString
            }
            let index = kyujitsuTupleArray.firstIndex(where: {$0.dayString == dateString})
            switch kyujitsuTupleArray[index!].type{
            case .heijitsu:
                cell.Label.textColor = UIColor.black
            case .kyujitsu:
                cell.Label.textColor = UIColor.red
            case .doyo:
                cell.Label.textColor = UIColor.blue
            }//switch kyujitsuTupleArray[index!].type
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedComponents.year = components.year
        selectedComponents.month = components.month
        selectedComponents.day = indexPath.row + weekdayAdding
        let selectedDay = cal.date(from: selectedComponents)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.dateFormat = "yyyy年M月d日"
        if dateLabel.text == dateFormatter.string(from: selectedDay!){
            let dateString = selectedDateFormatter.string(from: selectedDay!) + "\n"
            if isRevisedArray[selectedRow] == false{
                isRevisedArray[selectedRow] = true
                myPicker.reloadAllComponents()
            }
            var shitenShutenString = ""
            if selectedDateFormatter.string(from: selectedDay!) == startDayString{
                shitenShutenString = "始点"
            }
            if selectedDateFormatter.string(from: selectedDay!) == endDayString{
                shitenShutenString = "終点"
            }
            let cell = collectionView.cellForItem(at: indexPath) as! DNCollectionViewCell
            switch ableOrNot.selectedSegmentIndex{
            case 0://不可
                switch tochokuSegment.selectedSegmentIndex{
                case 0://clear
                    cell.Label.text = "\(indexPath.row + weekdayAdding)" + shitenShutenString
                    clearSavedData(dateString)
                case 1://当直
                    if let range = cell.Label.text!.range(of: "当◎"){
                        cell.Label.text?.replaceSubrange(range, with: "当×")
                        let range2 = savedArray[selectedRow].tochokuKibo?.range(of: dateString)
                        savedArray[selectedRow].tochokuKibo?.replaceSubrange(range2!, with: "")
                        if let i = savedArray[selectedRow].tochokuFuka{
                            savedArray[selectedRow].tochokuFuka = i + dateString
                        }
                        else{
                            savedArray[selectedRow].tochokuFuka = dateString
                        }
                    }
                    else{
                        if let range = cell.Label.text!.range(of: "当×"){
                            cell.Label.text?.replaceSubrange(range, with: "")
                            let range2 = savedArray[selectedRow].tochokuFuka?.range(of: dateString)
                            savedArray[selectedRow].tochokuFuka?.replaceSubrange(range2!, with: "")
                        }
                        else{
                            if let _ = cell.Label.text!.range(of: "\n"){
                                cell.Label.text = cell.Label.text! + "当×"
                            }
                            else{
                                cell.Label.text = cell.Label.text! + "\n当×"
                            }
                            if let i = savedArray[selectedRow].tochokuFuka{
                                savedArray[selectedRow].tochokuFuka = i + dateString
                            }
                            else{
                                savedArray[selectedRow].tochokuFuka = dateString
                            }
                        }
                    }
                default:
                    break
                }
            case 1://希望
                switch tochokuSegment.selectedSegmentIndex{
                case 0://clear
                    cell.Label.text = "\(indexPath.row + weekdayAdding)" + shitenShutenString
                    clearSavedData(dateString)
                case 1://当直
                    if let range = cell.Label.text!.range(of: "当×"){
                        cell.Label.text?.replaceSubrange(range, with: "当◎")
                        let range2 = savedArray[selectedRow].tochokuFuka?.range(of: dateString)
                        savedArray[selectedRow].tochokuFuka?.replaceSubrange(range2!, with: "")
                        if let i = savedArray[selectedRow].tochokuKibo{
                            savedArray[selectedRow].tochokuKibo = i + dateString
                        }
                        else{
                            savedArray[selectedRow].tochokuKibo = dateString
                        }
                    }
                    else{
                        if let range = cell.Label.text!.range(of: "当◎"){
                            cell.Label.text?.replaceSubrange(range, with: "")
                            let range2 = savedArray[selectedRow].tochokuKibo?.range(of: dateString)
                            savedArray[selectedRow].tochokuKibo?.replaceSubrange(range2!, with: "")
                        }
                        else{
                            if let _ = cell.Label.text!.range(of: "\n"){
                                cell.Label.text = cell.Label.text! + "当◎"
                            }
                            else{
                                cell.Label.text = cell.Label.text! + "\n当◎"
                            }
                            if let i = savedArray[selectedRow].tochokuKibo{
                                savedArray[selectedRow].tochokuKibo = i + dateString
                            }
                            else{
                                savedArray[selectedRow].tochokuKibo = dateString
                            }
                        }
                    }
                default:
                    break
                }
            default:
                break
            }
            print("**" + selectedDateFormatter.string(from: selectedDay!))
            if let i = savedArray[selectedRow].tochokuFuka{
                print("当直不可" + i)
            }
            if let i = savedArray[selectedRow].tochokuKibo{
                print("当直希望" + i)
            }
            if cell.Label.text == "\(indexPath.row + weekdayAdding)\n"{
                cell.Label.text = "\(indexPath.row + weekdayAdding)"
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
    func clearSavedData(_ dateString:String){
        if var i = savedArray[selectedRow].tochokuFuka{
            if let range = i.range(of: dateString){
                i.replaceSubrange(range, with: "")
                savedArray[selectedRow].tochokuFuka = i
            }
        }
        if var i = savedArray[selectedRow].tochokuKibo{
            if let range = i.range(of: dateString){
                i.replaceSubrange(range, with: "")
                savedArray[selectedRow].tochokuKibo = i
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }//func clearSavedData(dateString:String)
    
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
        isRevisedArray = [Bool](repeating: false, count: savedArray.count)
        myCollectionView.reloadData()
        myPicker.reloadAllComponents()
        kyujitsuHantei()
        kyujitsuHantei2()
        kaisuHantei()
    }
    
    @IBAction func myActionJigetsu(){
        components.month = components.month! + 1
        calculation()
        isRevisedArray = [Bool](repeating: false, count: savedArray.count)
        myCollectionView.reloadData()
        myPicker.reloadAllComponents()
        kyujitsuHantei()
        kyujitsuHantei2()
        kaisuHantei()
    }
    
    @objc func numberOfComponentsInPickerView(_ pickerView: UIPickerView!) -> Int {
        return 1
    }
    
    @objc func pickerView(_ pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        return savedArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if savedArray.count == 0{
            return
        }
        selectedRow = row
        selectedPerson = savedArray[row].name!
        self.navigationItem.title = selectedPerson + "当直希望"
        myCollectionView.reloadData()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        var c = ""
        if savedArray.count >= 1{
            c = savedArray[row].name!
            if isRevisedArray[row]{
                c = "✔︎" + c
            }
        }
        return c
    }
    
    func bunbohosei(_ bunbo: Double) -> Double{
        var c = bunbo
        if bunbo == 0.0{
            c = 0.001
        }
        if bunbo == 1.0{
            c = 0.01
        }
        if bunbo == 2.0{
            c = 0.03
        }
        if bunbo == 3.0{
            c = 2.0
        }
        return c
    }
    
    @IBAction func myActionNyuryokuKanryo(){
        if savedArray.count == 0{
            return
        }//if savedArray.count == 0
        let selectedDateFormatter = DateFormatter()
        var yusenScores = [YusenScore]()
        var isCompleted = false
        var isKaisuIcchi = true
        var isRenchokuNashi = true
        for shikoCounter in 0 ..< 50 {
            if isCompleted {
                print("\(shikoCounter)回目で完了！")
                break
            }
        let doctorCount = savedArray.count
        let daysCountInMonth = filteredTupleArray.count
        let donichiTotal = filteredTupleArray.filter{$0.type == .doyo}.count + filteredTupleArray.filter{$0.type == .kyujitsu}.count
        let donichiMax = Int(ceil(Double(donichiTotal)/Double(doctorCount)))
        print("donichiMax = \(donichiMax)")
        var donichiKaisu = [Int](repeating: 0, count: doctorCount)
        var tochokuKaisu = [Int](repeating: 0, count: doctorCount)
        var intervalTochoku = [Int](repeating: 0, count: doctorCount)
        for i in 0 ..< doctorCount{
            if savedArray[i].tochokukai >= 1{
                intervalTochoku[i] = Int(30 / savedArray[i].tochokukai)
            }
        }
        //yushinKiboArray[Dr.Index][その月の日付] = true or false (Boolean)
        var tochokuKiboArray = [[Bool]]()
        var tochokuFukaArray = [[Bool]]()
        var tochokuKiboAdding = [Int](repeating: 0, count: daysCountInMonth)
        var tochokuFukaAdding = [Int](repeating: 0, count: daysCountInMonth)
        for _ in 0 ..< doctorCount{
            tochokuKiboArray.append([])
            tochokuFukaArray.append([])
        }
        for i in 0 ..< doctorCount{
            tochokuKiboArray[i] = [Bool](repeating: false, count: daysCountInMonth)
            tochokuFukaArray[i] = [Bool](repeating: false, count: daysCountInMonth)
        }
        //typealias YusenScore = (aDay: Int, type: TochokuType, yScore: Int)
        //typealias KyujitsuTuple = (aDay:Int, dayString:String, dayDate:Date, type:DayType)
        
        for i in 0 ..< daysCountInMonth{
            switch filteredTupleArray[i].type{
            case .heijitsu:
                yusenScores.append((i + 1,.tochoku, Int(arc4random_uniform(100))))
            case .doyo:
                yusenScores.append((i + 1, .tochoku, Int(arc4random_uniform(100))))
            case .kyujitsu:
                yusenScores.append((i + 1,.tochoku, Int(arc4random_uniform(100))))
            }//switch filteredTupleArray[i].type
        }//for i in 0 ..< daysCountInMonth!
        var scoreArray = [Int](repeating: 0, count:yusenScores.count)
        for i in 0 ..< yusenScores.count{
            let a = yusenScores[i].aDay
            let b = yusenScores[i].type
            let c = yusenScores[i].yScore
            print("[\(i)] \(a)  \(b)  \(c)")
        }
        print ("\n")
        yusenScores.sort{$0.yScore > $1.yScore}
        for i in 0 ..< yusenScores.count{
            let a = yusenScores[i].aDay
            let b = yusenScores[i].type
            let c = yusenScores[i].yScore
            print("[\(i)] \(a)  \(b)  \(c)")
        }//for i in 0 ..< yusenScores.count
        print ("\n")
        for i in 0 ..< yusenScores.count{
            switch filteredTupleArray[yusenScores[i].aDay - 1].type{
            case .heijitsu:
                yusenScores[i].yScore = 0
            case .doyo:
                yusenScores[i].yScore = 10
            case .kyujitsu:
                yusenScores[i].yScore = 10
            }//switch filteredTupleArray[yusenScores[i].aDay - 1].type
        }//for i in 0 ..< yusenScores.count
        for i in 0 ..< yusenScores.count{
            let a = yusenScores[i].aDay
            let b = yusenScores[i].type
            let c = yusenScores[i].yScore
            print("[\(i)] \(a)  \(b)  \(c)")
        }//for i in 0 ..< yusenScores.count
        print ("\n")
        for i in 0 ..< doctorCount{
            for j in 0 ..< daysCountInMonth{
                let dateString = filteredTupleArray[j].dayString
                if let k = savedArray[i].tochokuKibo, let _ = k.range(of: dateString){
                    tochokuKiboArray[i][j] = true
                    tochokuKiboAdding[j] += 1
                }
                if let k = savedArray[i].tochokuFuka, let _ = k.range(of: dateString){
                    tochokuFukaArray[i][j] = true
                    tochokuFukaAdding[j] += 1
                }
            }//for j in 0 ..< daysCountInMonth!
        }//for i in 0 ..< doctorCount
        for i in 0 ..< daysCountInMonth{
            let dateString = filteredTupleArray[i].dayString
            var tochokuKiboString = "\n" + dateString + "当直希望 "
            var tochokuFukaString = "\n" + dateString + "当直不可 "
            for j in 0 ..< doctorCount{
                if tochokuKiboArray[j][i] {
                    tochokuKiboString += savedArray[j].name! + " "
                }
                if tochokuFukaArray[j][i] {
                    tochokuFukaString += savedArray[j].name! + " "
                }
            }//for j in 0 ..< doctorCount
            //各日付毎の不可・希望者表示
            print(tochokuKiboString)
            print(tochokuFukaString)
        }//for i in 0 ..< daysCountInMonth!
        for i in 0 ..< yusenScores.count{
            let day = yusenScores[i].aDay
            switch yusenScores[i].type{
            case .tochoku:
                yusenScores[i].yScore += tochokuFukaAdding[day - 1] + tochokuKiboAdding[day - 1]*20
            default:
                break
            }//switch yusenScores[i].type
        }//for i in 0 ..< yusenScores.count
        for i in 0 ..< yusenScores.count{
            let a = yusenScores[i].aDay
            let b = yusenScores[i].type
            let c = yusenScores[i].yScore
            print("[\(i)] \(a)  \(b)  \(c)")
        }//for i in 0 ..< yusenScores.count
        print ("\n")
        yusenScores.sort{$0.yScore > $1.yScore}
        for i in 0 ..< yusenScores.count{
            let a = yusenScores[i].aDay
            let b = yusenScores[i].type
            let c = yusenScores[i].yScore
            print("[\(i)] \(a)  \(b)  \(c)")
            yusenScores[i].yScore = -1
        }//for i in 0 ..< yusenScores.count
        for i in 0 ..< yusenScores.count{
            var testScores:[TestScore] = (0 ..< doctorCount).map{
                j in return (j,0)
            }
            let dateString = filteredTupleArray[yusenScores[i].aDay - 1].dayString
            for k in 0 ..< doctorCount{
                switch yusenScores[i].type{
                case .yushin:
                    continue
                case .nicchoku:
                    continue
                case .tochoku:
                    if let l = savedArray[k].tochokuFuka, let _ = l.range(of: dateString){
                        testScores[k].score = -256
                        continue
                    }//if let l = savedArray[k].tochokuFuka
                    if let l = savedArray[k].tochokuKibo, let _ = l.range(of: dateString){
                        testScores[k].score = 64
                        continue
                    }//if let l = savedArray[k].tochokuKibo
                }//switch yusenScores[i].type
                if testScores[k].score == 0{
                    testScores[k].score = Int(arc4random_uniform(8))
                }
                let f = yusenScores.filter{$0.yScore == k}
                if !f.isEmpty{
                    let g:[Int] = (0 ..< f.count).map{h in return abs(yusenScores[i].aDay - f[h].aDay)}
                    if g.min()! == 0{
                        testScores[k].score += -8
                    }
                    if g.min()! == 1{
                        testScores[k].score += -8
                    }
                    if g.min()! == 2{
                        testScores[k].score += -4
                    }
                    if g.min()! == 3{
                        testScores[k].score += -2
                    }
                }//if !f.isEmpty
                let ft = yusenScores.filter{$0.yScore == k && $0.type != .yushin}
                if !ft.isEmpty && yusenScores[i].type != .yushin{
                    let g:[Int] = (0 ..< ft.count).map{h in return abs(yusenScores[i].aDay - ft[h].aDay)}
                    if g.min()! >= intervalTochoku[k]{
                        testScores[k].score += 2
                    }
                    else{
                        testScores[k].score += -2
                    }
                }// if !ft.isEmpty && yusenScores[i].type != .yushin
                
                //        print ("\(savedArray[k].name ?? "") 日当直 \(ft.count) 夕診 \(fy.count) 計 \(f.count)")
                if yusenScores[i].type != .yushin && tochokuKaisu[k] == savedArray[k].tochokukai{
                    testScores[k].score += -128
                }
                if yusenScores[i].type != .yushin && tochokuKaisu[k] - Int(savedArray[k].tochokukai) == 1{
                    testScores[k].score += -256
                }
                if yusenScores[i].type != .yushin && tochokuKaisu[k] - Int(savedArray[k].tochokukai) >= 2{
                    testScores[k].score += -256
                }
                if filteredTupleArray[yusenScores[i].aDay - 1].type == .heijitsu, yusenScores[i].type != .yushin, tochokuKaisu[k] - Int(savedArray[k].tochokukai) == -1{
                    testScores[k].score += 2
                }
                if filteredTupleArray[yusenScores[i].aDay - 1].type == .heijitsu, yusenScores[i].type != .yushin, tochokuKaisu[k] - Int(savedArray[k].tochokukai) == -2{
                    testScores[k].score += 4
                }
                if filteredTupleArray[yusenScores[i].aDay - 1].type == .heijitsu, yusenScores[i].type != .yushin, tochokuKaisu[k] - Int(savedArray[k].tochokukai) <= -3{
                    testScores[k].score += 8
                }
                if filteredTupleArray[yusenScores[i].aDay - 1].type != .heijitsu, donichiKaisu[k] >= 1, donichiKaisu[k] < donichiMax{
                    testScores[k].score += -64
                }
                if filteredTupleArray[yusenScores[i].aDay - 1].type != .heijitsu && donichiKaisu[k] >= donichiMax{
                    testScores[k].score += -256
                }
            }//for k in 0 ..< doctorCount
            testScores.sort{ $0.score > $1.score }
            let a = yusenScores[i].aDay
            let b = yusenScores[i].type.rawValue
            let id = testScores[0].id
            yusenScores[i].yScore = id
            scoreArray[i] = testScores[0].score
            let c = savedArray[id].name
            //1日(ついたち)は、kyujitsuHeijitsuArray[0]となります。
            //typealias KyujitsuTuple = (aDay:Int, dayString:String, dayDate:Date, type:DayType)
            if filteredTupleArray[a - 1].type != .heijitsu{
                donichiKaisu[id] += 1
            }
                tochokuKaisu[id] += 1
            print("[\(i)] \(a)  \(b) \(c ?? "")  \(scoreArray[i])")
        }//for i in 0 ..< yusenScores.count
        yusenScores.sort{$0.aDay < $1.aDay}
        for i in 0 ..< yusenScores.count - 1{
            if yusenScores[i].aDay == yusenScores[i + 1].aDay && yusenScores[i].type == .tochoku{
                yusenScores.swapAt(i, i + 1)
            }
        }//for i in 0 ..< yusenScores.count - 1
        let b = yusenScores
        tochokuString = ""
        selectedComponents.year = components.year
        selectedComponents.month = components.month
        selectedComponents.day = 1
        
        selectedDateFormatter.locale = Locale(identifier: "ja_JP")
        selectedDateFormatter.dateFormat = "YYYY年M月"
        let monthString2 = selectedDateFormatter.string(from: filteredTupleArray[0].dayDate)
        tochokuString += monthString2 + "\t\t\t夕診\t\t3rd\n"
        for i in 0 ..< b.count{
            selectedComponents.year = components.year
            selectedComponents.month = components.month
            selectedComponents.day = b[i].aDay
            let selectedDay = filteredTupleArray[b[i].aDay - 1].dayDate
            let selectedDateFormatter = DateFormatter()
            selectedDateFormatter.locale = Locale(identifier: "ja_JP")
            selectedDateFormatter.dateFormat = "EE"
            let weekDayString = selectedDateFormatter.string(from: selectedDay)
            let hinichiFormatter = DateFormatter()
            hinichiFormatter.locale = Locale(identifier: "ja_JP")
            hinichiFormatter.dateFormat = "d日"
            let hinichiString = hinichiFormatter.string(from: selectedDay)
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
        print(tochokuString)
        //
        //
        //以下は、postAdjustmentです。
        //
        //
        var sogoInterval = [Double](repeating: 0.0, count: doctorCount)
        var tochokuInterval = [Double](repeating: 0.0, count: doctorCount)
        for i in 0 ..< doctorCount{
            let interval = yusenScores.filter{$0.yScore == i}.map{$0.aDay}
            let intervalT = yusenScores.filter{$0.yScore == i && $0.type != .yushin}.map{$0.aDay}
            if interval.count != 0{
                sogoInterval[i] = 30.0 / Double(interval.count)
            }
            if intervalT.count != 0{
                tochokuInterval[i] = 30.0 / Double(intervalT.count)
            }
            print("\(savedArray[i].name ?? "") \(interval) interval \(sogoInterval[i])")
            print("\(savedArray[i].name ?? "") 当直\(intervalT) interval \(tochokuInterval[i])")
        }//for i in 0 ..< doctorCount
        
        for i in 0 ..< yusenScores.count{
            if filteredTupleArray[yusenScores[i].aDay - 1].type != .heijitsu{
                continue
            }
            var dayIntervals = [DayInterval]()
            let yScore1 = yusenScores[i].yScore
            var originalTi = yusenScores.filter{$0.yScore == yScore1 && $0.type != .yushin}.map{$0.aDay}
            originalTi.sort{$0 < $1}
            var originalSi = yusenScores.filter{$0.yScore == yScore1}.map{$0.aDay}
            originalSi.sort{$0 < $1}
            var sumOTi = 0.0
            if originalTi.count >= 2{
                for myCount in 0 ..< originalTi.count - 1{
                    var bunbo = Double(originalTi[myCount + 1] - originalTi[myCount])
                    bunbo = bunbohosei(bunbo)
                    sumOTi += tochokuInterval[yScore1] / bunbo
                }//for myCount in 0 ..< originalTi.count - 1
            }//if originalTi.count >= 2
            var sumOSi = 0.0
            if originalSi.count >= 2{
                for myCount in 0 ..< originalSi.count - 1{
                    var bunbo = Double(originalSi[myCount + 1] - originalSi[myCount])
                    bunbo = bunbohosei(bunbo)
                    sumOSi += sogoInterval[yScore1] / bunbo
                }//for myCount in 0 ..< originalSi.count - 1
            }//if originalSi.count >= 2
            let iType = "tochoku"
            for j in 0 ..< yusenScores.count{
                if filteredTupleArray[yusenScores[j].aDay - 1].type != .heijitsu{
                    continue
                }
                var adjustScores = yusenScores
                let jType = "tochoku"
                if j == i || iType != jType || yusenScores[i].yScore == yusenScores[j].yScore{
                    continue
                }//if j == i || iType != jType || yusenScores[i].yScore == yusenScores[j].yScore
                let day1String = filteredTupleArray[yusenScores[i].aDay - 1].dayString
                let day2String = filteredTupleArray[yusenScores[j].aDay - 1].dayString
                let yScore2 = yusenScores[j].yScore
                if let k = savedArray[yScore1].tochokuFuka, let _ = k.range(of: day2String){continue}
                if let k = savedArray[yScore2].tochokuFuka, let _ = k.range(of: day1String){continue}
                if let k = savedArray[yScore1].tochokuKibo, let _ = k.range(of: day1String){continue}
                if let k = savedArray[yScore2].tochokuKibo, let _ = k.range(of: day2String){continue}
                adjustScores = yusenScores
                //    let iDay = yusenScores[i].aDay
                //    let jDay = yusenScores[j].aDay
                /*       print("i:\(iDay)日 \(savedArray[yScore1].name ?? "") j:\(jDay)日 \(savedArray[yScore2].name ?? "")") */
                adjustScores[i].yScore = yScore2
                adjustScores[j].yScore = yScore1
                var originalTj = yusenScores.filter{$0.yScore == yScore2 && $0.type != .yushin}.map{$0.aDay}
                originalTj.sort{$0 < $1}
                var adjustTi = adjustScores.filter{$0.yScore == yScore1 && $0.type != .yushin}.map{$0.aDay}
                adjustTi.sort{$0 < $1}
                var adjustTj = adjustScores.filter{$0.yScore == yScore2 && $0.type != .yushin}.map{$0.aDay}
                adjustTj.sort{$0 < $1}
                var originalSj = yusenScores.filter{$0.yScore == yScore2}.map{$0.aDay}
                originalSj.sort{$0 < $1}
                var adjustSi = adjustScores.filter{$0.yScore == yScore1}.map{$0.aDay}
                adjustSi.sort{$0 < $1}
                var adjustSj = adjustScores.filter{$0.yScore == yScore2}.map{$0.aDay}
                adjustSj.sort{$0 < $1}
                var sumOTj = 0.0
                if originalTj.count >= 2{
                    for myCount in 0 ..< originalTj.count - 1{
                        var bunbo = Double(originalTj[myCount + 1] - originalTj[myCount])
                        bunbo = bunbohosei(bunbo)
                        sumOTj += tochokuInterval[yScore2] / bunbo
                    }//for myCount in 0 ..< originalTj.count - 1
                }//if originalTj.count >= 2
                var sumATi = 0.0
                if adjustTi.count >= 2{
                    for myCount in 0 ..< adjustTi.count - 1{
                        var bunbo = Double(adjustTi[myCount + 1] - adjustTi[myCount])
                        bunbo = bunbohosei(bunbo)
                        sumATi += tochokuInterval[yScore1] / bunbo
                    }//for myCount in 0 ..< adjustTi.count - 1
                }//if adjustTi.count >= 2
                var sumATj = 0.0
                if adjustTj.count >= 2{
                    for myCount in 0 ..< adjustTj.count - 1{
                        var bunbo = Double(adjustTj[myCount + 1] - adjustTj[myCount])
                        bunbo = bunbohosei(bunbo)
                        sumATj += tochokuInterval[yScore2] / bunbo
                    }//for myCount in 0 ..< adjustTj.count - 1
                }//if adjustTj.count >= 2
                var sumOSj = 0.0
                if originalSj.count >= 2{
                    for myCount in 0 ..< originalSj.count - 1{
                        var bunbo = Double(originalSj[myCount + 1] - originalSj[myCount])
                        bunbo = bunbohosei(bunbo)
                        sumOSj += sogoInterval[yScore2] / bunbo
                    }//for myCount in 0 ..< originalSj.count - 1
                }//if originalSj.count >= 2
                var sumASi = 0.0
                if adjustSi.count >= 2{
                    for myCount in 0 ..< adjustSi.count - 1{
                        var bunbo = Double(adjustSi[myCount + 1] - adjustSi[myCount])
                        bunbo = bunbohosei(bunbo)
                        sumASi += sogoInterval[yScore1] / bunbo
                    }//for myCount in 0 ..< adjustSi.count - 1
                }//if adjustSi.count >= 2
                var sumASj = 0.0
                if adjustSj.count >= 2{
                    for myCount in 0 ..< adjustSj.count - 1{
                        var bunbo = Double(adjustSj[myCount + 1] - adjustSj[myCount])
                        bunbo = bunbohosei(bunbo)
                        sumASj += sogoInterval[yScore2] / bunbo
                    }//for myCount in 0 ..< adjustSi.count - 1
                }//if adjustSi.count >= 2
                
                dayIntervals.append((j,(sumATi + sumATj + sumASi + sumASj) - (sumOTi + sumOTj + sumOSi + sumOSj)))
            }//for j in 0 ..< yusenScores.count
            dayIntervals.sort{$0.interval < $1.interval}
            if dayIntervals.count != 0 ,dayIntervals[0].interval < 0{
                let iScore = yusenScores[i].yScore
                let jScore = yusenScores[dayIntervals[0].day].yScore
                yusenScores[i].yScore = jScore
                yusenScores[dayIntervals[0].day].yScore = iScore
                print ("\(yusenScores[i].aDay)日 \(yusenScores[i].type.rawValue) \(savedArray[iScore].name ?? "")と\(yusenScores[dayIntervals[0].day].aDay)日 \(yusenScores[dayIntervals[0].day].type.rawValue) \(savedArray[jScore].name ?? "")が交替 dayInterval=\(dayIntervals[0].interval)")
            }//if dayIntervals.count != 0 ,dayIntervals[0].interval < 0
        }//for i in 0 ..< yusenScores.count
        
            //以下は、回数と連直のチェック
            isKaisuIcchi = true
            isRenchokuNashi = true
            for i in 0 ..< savedArray.count {
                let filteredArray = yusenScores.filter{$0.yScore == i}
                var tochokuCount = 0
                tochokuCount = (filteredArray.filter{$0.type != .yushin}).count
                if tochokuCount != savedArray[i].tochokukai {
                    isKaisuIcchi = false
                    break
                }
                print("name, filteredArray.count = \(savedArray[i].name ?? "nobody"), \(filteredArray.count)")
                if filteredArray.count >= 2 {
                for j in 0 ..< filteredArray.count - 1 {
                    if filteredArray[j + 1].aDay - filteredArray[j].aDay <= 1 {
                        isRenchokuNashi = false
                        break
                    }
                }//for j in 0 ..< filteredArray.count - 1
                }
            }//for i in 0 ..< savedArray.count
            if isKaisuIcchi, isRenchokuNashi {
                print("isCompleted!!")
                isCompleted = true
            }//if isKaisuIcchi, isRenchokuNashi
        }//for shikoCounter in 0 ..< 50 (isCompleted == true となれば break してループを抜ける)
        if isCompleted == false {
            print("is NOT completed!!")
            var titleString = ""
            let messageString = "この案を候補として残しますか？"
            if isKaisuIcchi == false, isRenchokuNashi == true {
                titleString = "希望回数との不一致あり"
            }
            if isKaisuIcchi == true, isRenchokuNashi == false {
                titleString = "連直あり"
            }
            if isKaisuIcchi == false, isRenchokuNashi == false {
                titleString = "希望回数との不一致・連直あり"
            }
            let alert: UIAlertController = UIAlertController(title:titleString,message: messageString,preferredStyle: UIAlertController.Style.alert)
            let okAction: UIAlertAction = UIAlertAction(title: "残す",style: UIAlertAction.Style.default,handler:{(action:UIAlertAction!) -> Void in
                selectedDateFormatter.dateFormat = "yyyy年M月"
                let thisMonth = cal.date(from: components)
                let bufferMonth = selectedDateFormatter.string(from: thisMonth!)
                let serial = bufferScores.filter{$0.month == bufferMonth}.count
                bufferScores.append((month: bufferMonth, serial: serial, yusenTuple: yusenScores, firstDayDate: (self.filteredTupleArray.first?.dayDate)!, lastDayDate: (self.filteredTupleArray.last?.dayDate)!))
                bufferCount = serial + 1
                self.performSegue(withIdentifier: "toTochokuanYNNA", sender: true)
            })//let okAction: UIAlertAction
            let cancelAction = UIAlertAction(title: "破棄する", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }//if isCompleted == false
        if isCompleted {
            selectedDateFormatter.dateFormat = "yyyy年M月"
            let thisMonth = cal.date(from: components)
            let bufferMonth = selectedDateFormatter.string(from: thisMonth!)
            let serial = bufferScores.filter{$0.month == bufferMonth}.count
            bufferScores.append((month: bufferMonth, serial: serial, yusenTuple: yusenScores, firstDayDate: (filteredTupleArray.first?.dayDate)!, lastDayDate: (filteredTupleArray.last?.dayDate)!))
            bufferCount = serial + 1
            performSegue(withIdentifier: "toTochokuanYNNA", sender: true)
        }//if isCompleted
    }//@IBAction func myActionNyuryokuKanryo()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = "新規作成"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.navigationItem.title == "新規作成"{
            self.navigationItem.title = selectedPerson + "当直希望"
        }
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.dateFormat = "yyyy年M月"
        let selectedDay = cal.date(from: components)
        let bufferMonth = selectedDateFormatter.string(from: selectedDay!)
        let bCount = bufferScores.filter{$0.month == bufferMonth}.count
        if bCount == 0{
            self.kisakuButton.isEnabled = false
            self.kisakuButton.tintColor = UIColor.clear
        }
        else{
            self.kisakuButton.isEnabled = true
            self.kisakuButton.tintColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        }
        kyujitsuHantei2()
        self.myCollectionView.reloadData()
    }//override func viewWillAppear(_ animated: Bool)
}
