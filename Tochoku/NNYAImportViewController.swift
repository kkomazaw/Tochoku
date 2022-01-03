//
//  NNYAImportViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/10/28.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class NNYAImportViewController: UIViewController {
    
    var savedArray:[TochokuData] = []
    
    @IBOutlet var kibobiText:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = selectedPerson + "希望日・不可日"
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
    }//override func viewDidLoad()
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let index = savedArray.firstIndex(where:{$0.name == selectedPerson}) else {return}
        guard let _ = kibobiText.text.range(of: "当直回数") else {return}
        var arr = kibobiText.text.components(separatedBy: "\n")
        if kibobiText.text.range(of: "夕診") == nil{
            if let index = arr.firstIndex(where:{$0.contains("当直不可日")}){
                arr.insert("指定なし", at: index)
                arr.insert("夕診回数", at: index)
            }
            if let index = arr.firstIndex(where:{$0.contains("当直希望日")}){
                arr.insert("なし", at: index)
                arr.insert("夕診不可日", at: index)
            }
            arr.append("夕診希望日")
            arr.append("なし")
            var amendedText = ""
            for i in arr{
                amendedText += i
            }
            kibobiText.text = amendedText
        }//if kibobiText.text.range(of: "夕診") == nil
        let tochokukaisuIndex = arr.firstIndex(where:{$0.contains("当直回数")}) ?? 1
        let yushinkaisuIndex = arr.firstIndex(where:{$0.contains("夕診回数")}) ?? tochokukaisuIndex + 2
        let tochokufukabiIndex = arr.firstIndex(where:{$0.contains("当直不可日")}) ?? yushinkaisuIndex + 2
        let yushinfukabiIndex = arr.firstIndex(where:{$0.contains("夕診不可日")}) ?? tochokufukabiIndex + 2
        let tochokukibobiIndex = arr.firstIndex(where:{$0.contains("当直希望日")}) ?? yushinfukabiIndex + 2
        let yushinkibobiIndex = arr.firstIndex(where:{$0.contains("夕診希望日")}) ?? tochokukibobiIndex + 2
        print(tochokukaisuIndex)
        print(yushinkaisuIndex)
        print(tochokufukabiIndex)
        print(yushinfukabiIndex)
        print(tochokukibobiIndex)
        print(yushinkibobiIndex)
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.dateFormat = "yyyy年M月d日"
        var monthString = ""
        var daysCountInMonth = 31
        if tochokukaisuIndex >= 1, let i = selectedDateFormatter.date(from: (arr[tochokukaisuIndex - 1] + "1日")){
            monthString = arr[tochokukaisuIndex - 1]
            print(monthString)
            daysCountInMonth = (cal.range(of: .day, in: .month, for: i)?.count)!
            print(daysCountInMonth)
        }
        if let i = Int(arr[(tochokukaisuIndex) + 1]){
            savedArray[index].tochokukai = Int64(i)
        }
        if let i = Int(arr[(yushinkaisuIndex) + 1]){
            savedArray[index].yushinkai = Int64(i)
        }
        var tochokufukaArr = [String]()
        for i in tochokufukabiIndex + 1 ..< yushinfukabiIndex{
            if let _ = selectedDateFormatter.date(from: arr[i]){
                tochokufukaArr.append(arr[i])
                if let j = savedArray[index].tochokuFuka{
                    if j.range(of: arr[i]) == nil{
                        savedArray[index].tochokuFuka = j + arr[i] + "\n"
                    }
                }
            }
        }//for i in tochokufukabiIndex + 1 ..< yushinfukabiIndex
        var yushinfukaArr = [String]()
        for i in yushinfukabiIndex + 1 ..< tochokukibobiIndex{
            if let _ = selectedDateFormatter.date(from: arr[i]){
                yushinfukaArr.append(arr[i])
                if let j = savedArray[index].yushinFuka{
                    if j.range(of: arr[i]) == nil{
                        savedArray[index].yushinFuka = j + arr[i] + "\n"
                    }
                }
            }
        }//for i in yushinfukabiIndex + 1 ..< tochokukibobiIndex
        var tochokukiboArr = [String]()
        for i in tochokukibobiIndex + 1 ..< yushinkibobiIndex{
            if let _ = selectedDateFormatter.date(from: arr[i]){
                tochokukiboArr.append(arr[i])
                if let j = savedArray[index].tochokuKibo{
                    if j.range(of: arr[i]) == nil{
                        savedArray[index].tochokuKibo = j + arr[i] + "\n"
                    }
                }
            }
        }//for i in tochokukibobiIndex + 1 ..< yushinkibobiIndex
        var yushinkiboArr = [String]()
        for i in yushinkibobiIndex + 1 ..< arr.count{
            if let _ = selectedDateFormatter.date(from: arr[i]){
                yushinkiboArr.append(arr[i])
                if let j = savedArray[index].yushinKibo{
                    if j.range(of: arr[i]) == nil{
                        savedArray[index].yushinKibo = j + arr[i] + "\n"
                    }
                }
            }
        }//for i in yushinkibobiIndex + 1 ..< arr.count
        for i in 1 ... daysCountInMonth{
            let dayString = monthString + "\(i)日"
            if let j = savedArray[index].tochokuFuka, let range = j.range(of: dayString + "\n"), !tochokufukaArr.contains(dayString){
                savedArray[index].tochokuFuka?.replaceSubrange(range, with: "")
            }
            if let j = savedArray[index].yushinFuka, let range = j.range(of: dayString + "\n"), !yushinfukaArr.contains(dayString){
                savedArray[index].yushinFuka?.replaceSubrange(range, with: "")
            }
            if let j = savedArray[index].tochokuKibo, let range = j.range(of: dayString + "\n"), !tochokukiboArr.contains(dayString){
                savedArray[index].tochokuKibo?.replaceSubrange(range, with: "")
            }
            if let j = savedArray[index].yushinKibo, let range = j.range(of: dayString + "\n"), !yushinkiboArr.contains(dayString){
                savedArray[index].yushinKibo?.replaceSubrange(range, with: "")
            }
        }//for i in 1 ... daysCountInMonth
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }//override func viewWillDisappear(_ animated: Bool)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
