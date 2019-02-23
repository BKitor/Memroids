//
//  LandingPageViewController.swift
//  Memroids
//
//  Created by Paul Kitor on 2018-07-10.
//  Copyright © 2018 bkitor. All rights reserved.
//

import UIKit

var mainVC:LandingPageViewController?

class LandingPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var rememberButton: UIButton!
    @IBOutlet weak var saveTestButton: UIButton!
    
    var mems:[MemoryDataObject]?
    var fileURL:URL?
    var doc:MemoryDoc?

    var initalImage:UIImage?
    var initialTitle:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialising object variables that need initalisation
        mainVC = self
        initialiseDoc()
    }

    @IBAction func remember_touchUpInside(_ sender: Any) {
        performSegue(withIdentifier: "landingToTable", sender: self.rememberButton)
    }
    
    
    //Save feature, (ik that the name is test, but it's not, it's the final implementation of this function)
    //the following block of functions navigate through the save feature
    @IBAction func testSave_touchUpInside(_ sender: Any) {
        getNewMemoryData()
    }
    //create action sheet for deciding camera vs photo library, and calling picker controller
    func getNewMemoryData(){
        let actionSheet = UIAlertController(title: "Create memory from?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: transitionToCamera))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: transitionToPhotoLibrary))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    func transitionToPhotoLibrary(_ act:UIAlertAction){
        guard let picker = makePickerController(UIImagePickerControllerSourceType.photoLibrary) else {return}
        self.present(picker, animated: true, completion: nil)
    }
    func transitionToCamera(_ act:UIAlertAction){
        guard let picker = makePickerController(UIImagePickerControllerSourceType.camera) else {return}
        self.present(picker, animated: true, completion: nil)
    }
    func makePickerController(_ source:UIImagePickerControllerSourceType) -> UIImagePickerController?{
        guard UIImagePickerController.isSourceTypeAvailable(source) else {return nil}
        guard let arr = UIImagePickerController.availableMediaTypes(for: source) else {return nil}
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.mediaTypes = arr
        picker.delegate = self
        return picker
    }
    //when the image is picked, this funcion runs
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //creates and initialises the new memory editing page
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.initalImage = image
        picker.dismiss(animated: true, completion: getNewMemoryTitle)
    }
    //called avter imagePickerController runs, sets the titile for the new memery
    func getNewMemoryTitle(){
        let alert = UIAlertController(title: "Name of new memory", message: nil, preferredStyle: .alert)
        func handler(_ act:UIAlertAction){
            let tf = alert.textFields![0]
            self.initialTitle = tf.text
            performSegue(withIdentifier: "editMemory", sender: self.saveTestButton)
        }
        alert.addTextField { (tf) in
            tf.placeholder = "New Memory"
            tf.clearsOnBeginEditing = false
            tf.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.actions[0].isEnabled = false
        
        self.present(alert, animated: true, completion: nil)
    }
    //prepare for segue func, initialises MemoryEditingViewController,
    //the segue is called in getNewMemoryTitle, and
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender as? UIButton == self.saveTestButton{
            let editingController:MemoryEditingViewController2 = segue.destination as! MemoryEditingViewController2
            let memory = MemoryDataObject()
            memory.title = self.initialTitle!
            memory.images.append(self.initalImage)
            editingController.setMemory(memory)
            editingController.parentVC = self
        } else if sender as? UIButton == self.rememberButton{
            let tableVC = segue.destination as! MemoriesTableViewController
            tableVC.parentVC = self
        }
    }
    
    //when naming a new memory, this method is sent whenever the text field changes,
    //it activates the "ok" button if the text fild is populated.
    @objc func textChanged(_ sender:Any){
        //uses responder chaing to find UIAlertController
        let tf = sender as! UITextField
        var resp: UIResponder! = tf
        while !(resp is UIAlertController){ resp = resp.next}
        let alert = resp as!UIAlertController
        //check for empty
        alert.actions[0].isEnabled = (tf.text != "")
        //check for new name
        let name:String = tf.text!
        self.doc?.memories.forEach({ (mem) in
            if mem.title == name{
                alert.actions.first?.isEnabled = false
                return
            }
        })
        
        
    }
    
    //functions for initialising the document
    func initialiseDoc(){
        let directoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        self.fileURL = directoryURL.appendingPathComponent("MyMemories.memry")
        createDoc()
    }
    func createDoc(){
        self.doc = MemoryDoc(fileURL: self.fileURL!)
        if let _ = try? self.fileURL?.checkResourceIsReachable(){
            self.doc?.open(completionHandler: nil)
        }else{
            self.doc?.save(to: (self.doc?.fileURL)!, for: .forCreating, completionHandler: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
