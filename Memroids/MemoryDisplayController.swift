//
//  MemoryDisplayController.swift
//  Memroids
//
//  Created by Paul Kitor on 2018-07-30.
//  Copyright © 2018 bkitor. All rights reserved.
//


import UIKit
import Foundation

class MemoryDisplayController: UIViewController, UIScrollViewDelegate {

    var didMakeEdits:Bool = false
    var parentVC:MemoriesTableViewController?
    var memory:MemoryDataObject?
    var memoryIndex:Int?
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imagePageController: UIPageControl!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reminderDateLbl: UILabel!
    
    @objc func edit_touchUpInside(){
        performSegue(withIdentifier: "editExistingMemory", sender: self.navigationItem.rightBarButtonItem)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender as? UIBarButtonItem == self.navigationItem.rightBarButtonItem{
            let editingViewController:MemoryEditingViewController = (segue.destination as? MemoryEditingViewController)!
            editingViewController.setMemory(memory!)
            editingViewController.setMemoryIndex(memoryIndex!)
            editingViewController.parentVC = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //initialise views:
        let editButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(edit_touchUpInside))
        self.navigationItem.setRightBarButton(editButton, animated: false)
        self.navigationItem.title = memory?.title
        self.detailTextView.text = memory?.subtitle
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: (memory?.reminderDate)!)
        self.reminderDateLbl.text = dateString
        self.imageScrollView.showsHorizontalScrollIndicator = false
        self.imageScrollView.contentInsetAdjustmentBehavior = .never
        self.imageScrollView.delegate = self
        self.imagePageController.numberOfPages = (memory?.images.count)!

        //annoying and finiky scroll view set up
        self.view.layoutIfNeeded()
        let contentViewWidth = CGFloat((memory?.images.count)!) * imageScrollView.frame.width
        self.imageScrollView.contentSize = CGSize(width: contentViewWidth, height: imageScrollView.frame.height - (self.navigationController?.navigationBar.frame.height)! - 20)
        for i in 0..<memory!.images.count{
            let imView = UIImageView(frame:CGRect(x: imageScrollView.frame.width * CGFloat(i), y: 0, width: imageScrollView.frame.width, height: imageScrollView.contentSize.height))
            imView.image = memory!.images[i]
            imView.contentMode = .scaleAspectFit
            imageScrollView.addSubview(imView)
        }
        
    }
    
    func reloadView(){
        self.navigationItem.title = self.memory?.title
        self.detailTextView.text = self.memory?.subtitle
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: (memory?.reminderDate)!)
        self.reminderDateLbl.text = dateString
        
        let numViews = Int(imageScrollView.contentSize.width/imageScrollView.frame.width)
        
        if numViews<self.memory!.images.count{
            self.imagePageController.numberOfPages = self.memory!.images.count
            self.imageScrollView.contentSize.width = self.imageScrollView.frame.width * CGFloat(self.memory!.images.count)
            for i in numViews..<self.memory!.images.count{
                let imView = UIImageView(image: self.memory?.images[i])
                imView.frame = CGRect(x: self.imageScrollView.frame.width * CGFloat(i), y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
                imView.contentMode = .scaleAspectFit
                self.imageScrollView.addSubview(imView)
            }
        }
    }
    
    //checks if user swiped, and uptated page controller
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = imageScrollView.contentOffset.x / imageScrollView.frame.width
        imagePageController.currentPage = Int(currentPage)
    }
    func setMemory(_ mem:MemoryDataObject){
        self.memory = mem
    }
    func setMemoryIndex(_ i:Int){
        self.memoryIndex = i
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
