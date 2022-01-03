//
//  KyujitsuHenkoViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/10/30.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit

class KyujitsuHenkoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum DayType{
        case heijitsu
        case doyo
        case kyujitsu
    }
    
    var kyujitsuHeijitsuArray:Array<DayType> = []
    var thisClassComponents = DateComponents()
    
    @IBOutlet var dateLabel:UILabel!
    @IBOutlet var zengetsuButton:UIButton!
    @IBOutlet var jigetsuButton:UIButton!
    @IBOutlet var myCollectionView:UICollectionView!
    @IBOutlet var mySegment:UISegmentedControl!
    @IBOutlet var chushakuLabel:UILabel!
    var weekdayAdding = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kyujitsuHeijitsuArray = [DayType](repeating: .heijitsu, count: 31)
        holiday = holidayDefaults.string(forKey: "holiday")!
        nichiyouHeijitsuString = nichiyouHeijitsuDefaults.string(forKey: "nichiyouHeijitsuString")!
        cal.locale = Locale(identifier: "ja")
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy年M月"
        components.day = 1
        thisClassComponents = components
        calculation()
        if isSakuseisha{
            mySegment.isHidden = false
            self.navigationItem.title = "休日/期間変更"
        }
        else{
            mySegment.isHidden = true
            self.navigationItem.title = "休日変更"
        }
        kyujitsuHantei()
    }//override func viewDidLoad()
    
    override func viewDidAppear(_ animated: Bool) {
        kyujitsuHantei()
    }
    
    func kyujitsuHantei(){
        var localComponents = DateComponents()
        let firstDayOfMonth = cal.date(from: thisClassComponents)
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth!)
        weekdayAdding = 2 - firstWeekday
        let daysCountInMonth = cal.range(of: .day, in: .month, for: firstDayOfMonth!)?.count
        for i in 0 ..< 37{
            if (i + weekdayAdding) >= 1 && (i + weekdayAdding) <= daysCountInMonth!{
                localComponents.year = thisClassComponents.year
                localComponents.month = thisClassComponents.month
                localComponents.day = i + weekdayAdding
                let selectedDay = cal.date(from: localComponents)
                let selectedDateFormatter = DateFormatter()
                selectedDateFormatter.dateFormat = "yyyy年M月d日"
                let dateString = selectedDateFormatter.string(from: selectedDay!)
                //1日(ついたち)は、kyujitsuHeijitsuArray[0]となります。
                if i % 7 == 0{
                    kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .kyujitsu
                    if let _ = nichiyouHeijitsuString.range(of: dateString){
                        kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .heijitsu
                    }
                }//if i % 7 == 0
                else if i % 7 == 6{
                    kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .doyo
                    if isDoyoNicchoku {
                        kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .kyujitsu
                        if let _ = nichiyouHeijitsuString.range(of: dateString){
                            kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .heijitsu
                        } //if let _ = nichiyouHeijitsuString.range(of: dateString)
                    } //if isDoyoNicchoku
                } //else if i % 7 == 6
                else{
                    kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .heijitsu
                }
                if let _ = holiday.range(of: dateString){
                    kyujitsuHeijitsuArray[i + weekdayAdding - 1] = .kyujitsu
                }
            }//if (i + weekdayAdding) >= 1 && (i + weekdayAdding) <= daysCountInMonth
        }//for i in 0 ..< 37
    }//func kyujitsuHantei()
    
    func calculation(){
        let firstDayOfMonth = cal.date(from: thisClassComponents)
        dateLabel.text = dateFormatter.string(from: firstDayOfMonth!)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 37
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KyujitsuCell", for: indexPath) as! KyujitsuCollectionViewCell
        let firstDayOfMonth = cal.date(from: thisClassComponents)
        let firstWeekday = cal.component(.weekday, from: firstDayOfMonth!)
        weekdayAdding = 2 - firstWeekday
        
        let daysCountInMonth = cal.range(of: .day, in: .month, for: firstDayOfMonth!)?.count
        if (indexPath.row + weekdayAdding) >= 1 && (indexPath.row + weekdayAdding) <= daysCountInMonth! {
            cell.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
            var localComponents = DateComponents()
            localComponents.year = thisClassComponents.year
            localComponents.month = thisClassComponents.month
            localComponents.day = indexPath.row + weekdayAdding
            let selectedDateFormatter = DateFormatter()
            selectedDateFormatter.dateFormat = "yyyy年M月d日"
            let selectedDay = cal.date(from: localComponents)
            let dateString = selectedDateFormatter.string(from: selectedDay!)
            cell.Label.text = "\(indexPath.row + weekdayAdding)"
            if dateString == startDayString{
                cell.Label.text = "\(indexPath.row + weekdayAdding)\n始点"
            }
            if dateString == endDayString{
                cell.Label.text = "\(indexPath.row + weekdayAdding)\n終点"
            }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var localComponents = DateComponents()
        localComponents.year = thisClassComponents.year
        localComponents.month = thisClassComponents.month
        localComponents.day = indexPath.row + weekdayAdding
        let selectedDay = cal.date(from: localComponents)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.dateFormat = "yyyy年M月d日"
        let dateString = selectedDateFormatter.string(from: selectedDay!)
        //indexPath.row % 7 == 0 なら日曜、6なら土曜
        switch mySegment.selectedSegmentIndex {
        case 0:
            if indexPath.row % 7 == 0{
                if let range = nichiyouHeijitsuString.range(of: dateString){
                    nichiyouHeijitsuString.replaceSubrange(range, with: "")
                }
                else{
                    nichiyouHeijitsuString += dateString
                    print("日曜平日化 \(dateString)")
                }
            } //if (indexPath.row + weekdayAdding) % 7 == 0
            if indexPath.row % 7 != 0, !isDoyoNicchoku{
                if let range = holiday.range(of: dateString){
                    holiday.replaceSubrange(range, with: "")
                    print("\(dateString) が休日から削除")
                }
                else{
                    holiday += dateString
                    print("new holiday \(dateString)")
                }
            } //if indexPath.row % 7 != 0, !isDoyoNicchoku
            if indexPath.row % 7 != 0, indexPath.row % 7 != 6,isDoyoNicchoku{
                if let range = holiday.range(of: dateString){
                    holiday.replaceSubrange(range, with: "")
                    print("\(dateString) が休日から削除")
                }
                else{
                    holiday += dateString
                    print("new holiday \(dateString)")
                }
            } //if indexPath.row % 7 != 0, !isDoyoNicchoku
            if indexPath.row % 7 == 6, isDoyoNicchoku {
                if let range = nichiyouHeijitsuString.range(of: dateString){
                    nichiyouHeijitsuString.replaceSubrange(range, with: "")
                }
                else{
                    nichiyouHeijitsuString += dateString
                    print("日曜平日化 \(dateString)")
                }
            } //if indexPath.row % 7 == 6, isDoyoNicchoku
            kyujitsuHantei()
            holidayDefaults.set(holiday, forKey: "holiday")
            nichiyouHeijitsuDefaults.set(nichiyouHeijitsuString, forKey:"nichiyouHeijitsuString")
            myCollectionView.reloadData()
        case 1:
            if startDayString == dateString{
                startDayString = ""
            }
            else{
                startDayString = dateString
            }
            print("開始日 \(startDayString)")
            myCollectionView.reloadData()
        case 2:
            if endDayString == dateString{
                endDayString = ""
            }
            else{
                endDayString = dateString
            }
            print("終了日 \(endDayString)")
            myCollectionView.reloadData()
        default:
            break
        }//switch mySegment.selectedSegmentIndex
        holidayDefaults.set(holiday, forKey: "holiday")
        nichiyouHeijitsuDefaults.set(nichiyouHeijitsuString, forKey:"nichiyouHeijitsuString")
    }//func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    
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
        thisClassComponents.month = thisClassComponents.month! - 1
        calculation()
        myCollectionView.reloadData()
        kyujitsuHantei()
    }
    
    @IBAction func myActionJigetsu(){
        thisClassComponents.month = thisClassComponents.month! + 1
        calculation()
        myCollectionView.reloadData()
        kyujitsuHantei()
    }
    
    @IBAction func myActionSegmentChange(){
        switch mySegment.selectedSegmentIndex {
        case 0:
            chushakuLabel.text = "※休日⇄平日をクリックで切り替え"
        case 1:
            chushakuLabel.text = "※当直始点を1日以外に変更"
        case 2:
            chushakuLabel.text = "※当直終点を月末以外に変更"
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
