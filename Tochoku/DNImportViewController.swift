//
//  DNImportViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/10/29.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class DNImportViewController: UIViewController {
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
        let arr = kibobiText.text.components(separatedBy: "\n")
        let tochokukaisuIndex = arr.firstIndex(where:{$0.contains("当直回数")}) ?? 1
        let tochokufukabiIndex = arr.firstIndex(where:{$0.contains("当直不可日")}) ?? tochokukaisuIndex + 2
        let tochokukibobiIndex = arr.firstIndex(where:{$0.contains("当直希望日")}) ?? tochokufukabiIndex + 2
        print(tochokukaisuIndex)
        print(tochokufukabiIndex)
        print(tochokukibobiIndex)
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
        var tochokufukaArr = [String]()
        for i in tochokufukabiIndex + 1 ..< tochokukibobiIndex{
            if let _ = selectedDateFormatter.date(from: arr[i]){
                tochokufukaArr.append(arr[i])
                if let j = savedArray[index].tochokuFuka{
                    if j.range(of: arr[i]) == nil{
                        savedArray[index].tochokuFuka = j + arr[i] + "\n"
                    }
                }
            }
        }//for i in tochokufukabiIndex + 1 ..< tochokukibobiIndex
        var tochokukiboArr = [String]()
        for i in tochokukibobiIndex + 1 ..< arr.count{
            if let _ = selectedDateFormatter.date(from: arr[i]){
                tochokukiboArr.append(arr[i])
                if let j = savedArray[index].tochokuKibo{
                    if j.range(of: arr[i]) == nil{
                        savedArray[index].tochokuKibo = j + arr[i] + "\n"
                    }
                }
            }
        }//for i in tochokukibobiIndex + 1 ..< arr.count
        for i in 1 ... daysCountInMonth{
            let dayString = monthString + "\(i)日"
            if let j = savedArray[index].tochokuFuka, let range = j.range(of: dayString + "\n"), !tochokufukaArr.contains(dayString){
                savedArray[index].tochokuFuka?.replaceSubrange(range, with: "")
            }
            if let j = savedArray[index].tochokuKibo, let range = j.range(of: dayString + "\n"), !tochokukiboArr.contains(dayString){
                savedArray[index].tochokuKibo?.replaceSubrange(range, with: "")
            }
        }//for i in 1 ... daysCountInMonth
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }//override func viewWillDisappear(_ animated: Bool)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
