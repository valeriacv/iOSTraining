//
//  ListDetailViewController.swift
//  Checklists
//
//  Created by Vale Calderon  on 4/3/17.
//  Copyright © 2017 Vale Calderon . All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate {

  var dataModel: DataModel!

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    navigationController?.delegate = self
    
    let index = dataModel.indexOfSelectedChecklist
    if index >= 0 && index < dataModel.lists.count {
      let checklist = dataModel.lists[index]
      performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  /*
   @name: tableView -> tableView(numberOfRowsInSection)
   @description: return the amount of rows the table view is going to have
   */
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataModel.lists.count
  }
  
  /*
   @name: tableView -> tableView(cellForRowAt)
   @description: sets the cell, with is characteristics, that is going to be in the cell with the position IndexPath
   */
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = makeCell(for: tableView)

    let checklist = dataModel.lists[indexPath.row]
    cell.textLabel!.text = checklist.name
    cell.accessoryType = .detailDisclosureButton
    
    let count = checklist.countUncheckedItems()
    if checklist.items.count == 0 {
      cell.detailTextLabel!.text = "(No Items)"
    } else if count == 0 {
      cell.detailTextLabel!.text = "All Done!"
    } else {
      cell.detailTextLabel!.text = "\(count) Remaining"
    }
    
    cell.imageView!.image = UIImage(named: checklist.iconName)
    return cell
  }

  
  /*
      @name: makeCell
      @description: creates a cell for the table view, if it can get a reusable, then it returns the reusable cell
   */
  func makeCell(for tableView: UITableView) -> UITableViewCell {
    let cellIdentifier = "Cell"
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
      return cell
    } else {
      return UITableViewCell(style: .subtitle,reuseIdentifier: cellIdentifier)
    }
  }
  
  
   /*
      @name: tableView -> tableView(didSelectRowAt)
      @description: event when a cell(that represents a checklists) is selected in the view,
                  calls the checklist view controller with the specific data of the requested list.
   */
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    dataModel.indexOfSelectedChecklist = indexPath.row
    let checklist = dataModel.lists[indexPath.row]
    performSegue(withIdentifier: "ShowChecklist", sender: checklist)
  }
  
  /*
   @name: tableView -> tableView(editingStyle)
   @description: event when a cell is deleted
   */
  override func tableView(_ tableView: UITableView,commit editingStyle: UITableViewCellEditingStyle,forRowAt indexPath: IndexPath) {
    dataModel.lists.remove(at: indexPath.row)
    
    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
  }
  
  /*
      @name: tableView -> tableView(accessoryButtonTappedForRowWith)
      @description: event the button of a row is tapped, calls the view with the details of the selected list
   */
  override func tableView(_ tableView: UITableView,accessoryButtonTappedForRowWith indexPath: IndexPath) {
    
    let navigationController = storyboard!.instantiateViewController(withIdentifier: "ListDetailNavigationController") as! UINavigationController
    
    let controller = navigationController.topViewController as! ListDetailViewController
    controller.delegate = self
    
    let checklist = dataModel.lists[indexPath.row]
    controller.checklistToEdit = checklist
    
    present(navigationController, animated: true, completion: nil)
  }
  
  
  /*
      @name: prepare 
      @description: depending on the action and the next view the user wants to see, the segue with the correct identifier will do the transition
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowChecklist" {
      let controller = segue.destination as! ChecklistViewController
      controller.checklist = sender as! Checklist

    } else if segue.identifier == "AddChecklist" {
      let navigationController = segue.destination as! UINavigationController
      let controller = navigationController.topViewController as! ListDetailViewController
      controller.delegate = self
      controller.checklistToEdit = nil
    }
  }
  
  /*
   @name: listDetailViewControllerDidCancel
   @description: close the view of the details of the list
   */
  func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  /*
      @name: listDetailViewControllerDidCancel -> listDetailViewControllerDidCancel(didFinishAdding)
      @description: add a new checklist
   */
  func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
    dataModel.lists.append(checklist)
    dataModel.sortChecklists()
    tableView.reloadData()
    dismiss(animated: true, completion: nil)
  }
  
  /*
      @name: listDetailViewControllerDidCancel -> listDetailViewControllerDidCancel(didFinishEditing)
      @description: edits a list
   */
  func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
    dataModel.sortChecklists()
    tableView.reloadData()
    dismiss(animated: true, completion: nil)
  }
  
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    // Was the back button tapped?
    if viewController === self {
      dataModel.indexOfSelectedChecklist = -1
    }
  }
}
