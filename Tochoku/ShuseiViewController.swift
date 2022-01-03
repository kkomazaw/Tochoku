//
//  ShuseiViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/03/04.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class ShuseiViewController: UIViewController {
    
    @IBOutlet var IshimeiLabel:UILabel!
    @IBOutlet var TochokuKaisu:UITextField!
    @IBOutlet var YushinKaisu:UITextField!
    @IBOutlet var TorokuButton:UIButton!
    @IBOutlet var YushinkaisuLabel:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if isYushin{
            YushinKaisu.isHidden = false
            YushinkaisuLabel.isHidden = false
        }
        else{
            YushinKaisu.isHidden = true
            YushinkaisuLabel.isHidden = true
        }
        let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            let fetchRequest:NSFetchRequest<TochokuData> = TochokuData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format:"name = %@", selectedPerson)
            let fetchedArray = try myContext.fetch(fetchRequest)
            IshimeiLabel.text = fetchedArray[0].name
            TochokuKaisu.text = String(fetchedArray[0].tochokukai)
            if isYushin{
                YushinKaisu.text = String(fetchedArray[0].yushinkai)
            }
        }
        catch{
            print("fetching failed")
        }
        
    }
    
    @IBAction func nyuryokuKanryo(){
        let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            let fetchRequest:NSFetchRequest<TochokuData> = TochokuData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format:"name = %@", selectedPerson)
            let fetchedArray = try myContext.fetch(fetchRequest)
            fetchedArray[0].tochokukai = Int64(TochokuKaisu.text!)!
            if isYushin{
                fetchedArray[0].yushinkai = Int64(YushinKaisu.text!)!
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        catch{
            print("fetching failed")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
