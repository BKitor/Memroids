//
//  MemoriesTableViewController.swift
//  Memroids
//
//  Created by Paul Kitor on 2018-07-10.
//  Copyright © 2018 bkitor. All rights reserved.
//TODO:implement order syustem

/*aug 27 plan:
 2.when row is selected, iterate name through memories and identify index of proper memory
*/

import UIKit
import Foundation

class MemoriesTableViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    var parentVC:LandingPageViewController?
    var memories:[MemoryDataObject]{
        get{return (parentVC?.doc?.memories)!}
        set{parentVC?.doc?.memories = newValue}
    }
    var currentArray = [MemoryDataObject]()
    //used in prepare for segue, stores the row index the user tapped
    var selectedRow:Int = -1
    var originalIndex:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        currentArray = memories
        self.searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        <#code#>
    }
    
    //updates UIViewList whenever the user types something
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentArray = memories
            tableView.reloadData()
            return
        }
        currentArray = memories.filter({ (mem) -> Bool in
            mem.title.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    //for when the user selects a row,
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "displayMemory", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let displayView:MemoryDisplayController = segue.destination as! MemoryDisplayController
        self.selectedRow = (self.tableView.indexPathForSelectedRow?.row)!
        
        for i in 0..<self.parentVC!.doc!.memories.count{
            if self.parentVC?.doc?.memories[i].title == self.currentArray[selectedRow].title{
                self.originalIndex = i
            }
        }
        
        displayView.setMemory(self.currentArray[selectedRow])
        displayView.setMemoryIndex(originalIndex)
        displayView.parentVC = self
    }
    
    //cellForRowAt (Gives the tableView stuff to present)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memory", for: indexPath)
        // Configure the cell...
        cell.textLabel?.text = self.currentArray[indexPath.row].title
        let formater = DateFormatter()
        formater.timeStyle = .none
        formater.dateStyle = .long
        let dateCreatedLableText = formater.string(from: self.currentArray[indexPath.row].dateCreated)
        cell.detailTextLabel?.text = dateCreatedLableText
        return cell
    }
    
    //commit editing style (used for deleting cells)
    override func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //UIAllert confirming delition of memory
        if editingStyle == .delete{
        func removeRow(_ act:UIAlertAction){
            //removes memory from displaying and saved data array
            self.memories.remove(at: indexPath.row)
            self.currentArray = self.memories
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            //update saved file
            mainVC?.doc?.save(to: (mainVC?.doc?.fileURL)!, for: .forOverwriting, completionHandler: nil)
        }
        //warning that actions is ireversable
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete this memory, this action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: removeRow))
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.currentArray.count
    }
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
