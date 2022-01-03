//
//  HozonTableViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/09/17.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class HozonTableViewController: UITableViewController {
    
    var hozonArray:[HozonData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            
            let sortDescripter = NSSortDescriptor(key: "month", ascending: false)
            let fetchRequest: NSFetchRequest<HozonData> = HozonData.fetchRequest()
            fetchRequest.sortDescriptors = [sortDescripter]
            hozonArray = try myContext.fetch(fetchRequest)
        }
        catch {
            print("Fetching Failed.")
        }
     self.clearsSelectionOnViewWillAppear = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }//override func viewDidLoad()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var c = 0
        if hozonArray.count > 0{
            c = hozonArray.count
        }
        return c
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "date", for: indexPath)
     let arr = hozonArray[indexPath.row].tochokuhyo?.components(separatedBy: "\t")
     cell.textLabel!.text = arr?[0]
     cell.textLabel?.adjustsFontSizeToFitWidth = true
     cell.textLabel?.minimumScaleFactor = 0.5
     return cell
    }

    
    // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     tochokuString = hozonArray[indexPath.row].tochokuhyo!
        hozonIndex = indexPath.row
     }

     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     tableView.isEditing = true
     if editingStyle == .delete {
     let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
     myContext.delete(hozonArray[indexPath.row])
     (UIApplication.shared.delegate as! AppDelegate).saveContext()
     hozonArray.remove(at: indexPath.row)
     tableView.deleteRows(at: [indexPath], with: .fade)
     }
     }

}
