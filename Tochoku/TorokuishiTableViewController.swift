//
//  TorokuishiTableViewController.swift
//  Tochoku
//
//  Created by Matsui Keiji on 2018/03/03.
//  Copyright © 2018年 Matsui Keiji. All rights reserved.
//

import UIKit
import CoreData

class TorokuishiTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var savedArray:[TochokuData] = []
    var unfilteredNFLTeams:Array<String> = []
    var filteredNFLTeams:Array<String> = []
    let searchController = UISearchController(searchResultsController: nil)
    
    func myCalc(){
        unfilteredNFLTeams.removeAll()
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
        if savedArray.count == 0{
            return
        }
        for i in 0 ..< savedArray.count{
            unfilteredNFLTeams.append(savedArray[i].name!)
        }
        filteredNFLTeams = unfilteredNFLTeams
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    } //func myCalc()
    
    func myCalc2(){
        unfilteredNFLTeams.removeAll()
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
        if savedArray.count == 0{
            return
        }
        for i in 0 ..< savedArray.count{
            unfilteredNFLTeams.append(savedArray[i].name!)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "検索"
        tableView.tableHeaderView = searchController.searchBar
        super.viewDidLoad()
        myCalc()
        self.clearsSelectionOnViewWillAppear = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNFLTeams.count
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredNFLTeams = unfilteredNFLTeams.filter { team in
                return team.lowercased().contains(searchText.lowercased())
            }
            
        } else {
            filteredNFLTeams = unfilteredNFLTeams
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Reuse", for: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel!.text = filteredNFLTeams[indexPath.row]
        let indexOfSelectedRow = unfilteredNFLTeams.firstIndex(of: filteredNFLTeams[indexPath.row])
        let detailTochokukai = String(savedArray[indexOfSelectedRow!].tochokukai)
        if isYushin{
            let detailYushinkai = String(savedArray[indexOfSelectedRow!].yushinkai)
            cell.detailTextLabel?.text = "当直" + detailTochokukai + " 夕診" + detailYushinkai
        }
        else{
            cell.detailTextLabel?.text = "当直" + detailTochokukai
        }
        cell.textLabel?.minimumScaleFactor = 0.5
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPerson = filteredNFLTeams[indexPath.row]
    //    performSegue(withIdentifier: "toShuseiView", sender: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let indexOfSelectedRow = unfilteredNFLTeams.firstIndex(of: filteredNFLTeams[indexPath.row])
            if indexOfSelectedRow == nil{
                return
            }
            myContext.delete(savedArray[indexOfSelectedRow!])
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            unfilteredNFLTeams.remove(at: indexOfSelectedRow!)
            filteredNFLTeams.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            myCalc2()
        }
    }
    
    @IBAction func fromShuseiToTorokuishi(_ Segue:UIStoryboardSegue){
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }

}
