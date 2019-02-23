//
//  MemoryEditingViewController.swift
//  Memroids
//
//  Created by Paul Kitor on 2018-08-01.
//  Copyright © 2018 bkitor. All rights reserved.
//

//TODO:refresh imageScrollView after saving editing


import UIKit

class MemoryEditingViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didEditTitle = false
    var parentVC:MemoryDisplayController?
    var memory:MemoryDataObject?
    var memoryIndex:Int?
    var displayViews:[UIImageView] = []
    
    @IBOutlet weak var removeImageButton: UIButton!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    @IBOutlet weak var imagePageController: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //initialise views:
        navigationItem.title = memory?.title
        self.titleTextField.text = memory?.title
        self.detailTextView.text = memory?.subtitle
        self.reminderDatePicker.date = (memory?.reminderDate)!
        setUpScrollView()
        self.imagePageController.numberOfPages = (memory?.images.count)!
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItem = saveButton
        self.removeImageButton.isEnabled = self.displayViews.count != 1
    }

    
    //save, Called when BarButtonItem saveButton is pressed
    @objc func save(){
        //makes sure there are no duplicate names
        if !nameIsUnique(){
            return
        }
        
        let landingPage = self.parentVC!.parentVC!.parentVC!
        self.parentVC?.didMakeEdits = true
        
        saveMemory()
        
        self.parentVC?.memory = self.memory
        
        landingPage.doc?.memories.remove(at: self.memoryIndex!)
        landingPage.doc?.memories.insert(self.memory!, at: self.memoryIndex!)
        
        //Do not let this call be placed in the final run, change to UpdateWhachemecallit for releace
        landingPage.doc?.save(to: (landingPage.doc?.fileURL)!, for: .forOverwriting, completionHandler: nil)
        
        self.parentVC?.reloadView()
        self.navigationController?.popViewController(animated: true)
        
        if didEditTitle{
            self.parentVC?.parentVC?.tableView.reloadData()
        }
    }

    //updates self.memory to hold the values the user inputed
    func saveMemory(){
        self.didEditTitle = !(self.memory!.title == self.titleTextField.text)
        self.memory?.title = self.titleTextField.text!
        self.memory?.subtitle = self.detailTextView.text
        self.memory?.reminderDate = self.reminderDatePicker.date
    }

    //series of fucntinos to add new image, reletive copy and paste form landing, and the other editing
    @IBAction func addImeges_touchUpInside(_ sender: Any) {
        let actionSheet = UIAlertController(title: "New Image", message: "Add new image form?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: transitionToCamera))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: transitionToPhotoLibrary))
        actionSheet.addAction(UIAlertAction(title: "Calcel", style: .cancel, handler: nil))
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //update data in memObj
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.memory?.images.append(image)
        //update frame of scrollViewController
        let newScrollViewSize = CGSize(width: imageScrollView.frame.width * CGFloat((self.memory?.images.count)!), height: imageScrollView.frame.height)
        imageScrollView.contentSize = newScrollViewSize
        //add new Image to scroll View
        let imageFrame = CGRect(x: CGFloat((self.memory?.images.count)! - 1) * imageScrollView.frame.width, y: 0, width: imageScrollView.frame.width, height: imageScrollView.frame.height)
        let imView = UIImageView(image: image)
        imView.contentMode = .scaleAspectFit
        imView.frame = imageFrame
        self.displayViews.append(imView)
        self.imageScrollView.addSubview(self.displayViews.last!)
        self.imagePageController.numberOfPages += 1
        
        let anim = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
            let dest = self.imageScrollView.contentSize.width - self.imageScrollView.frame.width
            self.imageScrollView.contentOffset.x = dest
            let pageNumber = self.imageScrollView.contentOffset.x / self.imageScrollView.frame.width
            self.imagePageController.currentPage = Int(pageNumber)
        }
        self.removeImageButton.isEnabled = true
        picker.dismiss(animated: true) {
            anim.startAnimation()
        }

    }
    //used for updateing pageViewController's current page
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = imageScrollView.contentOffset.x / imageScrollView.frame.width
        imagePageController.currentPage = Int(pageNumber)
    }
    //Scroll View set up
    func setUpScrollView(){
        self.view.layoutIfNeeded()
        self.imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width * CGFloat((memory?.images.count)!), height: imageScrollView.frame.height - 20 - (self.navigationController?.navigationBar.frame.height)!)
        self.imageScrollView.showsHorizontalScrollIndicator = false
        self.imageScrollView.delegate = self
        for i in 0..<memory!.images.count{
            let imView = UIImageView(image: memory?.images[i])
            imView.frame = CGRect(x: CGFloat(i) * imageScrollView.frame.width, y: 0, width: imageScrollView.frame.width, height: imageScrollView.contentSize.height)
            imView.contentMode = .scaleAspectFit
            self.displayViews.append(imView)
            self.imageScrollView.addSubview(self.displayViews.last!)
        }
        print(imageScrollView.frame)
    }
    
    @IBAction func removeImage_touchUpInside(_ sender: Any) {
        let selectedImage = Int(self.imageScrollView.contentOffset.x/self.imageScrollView.frame.width)
        
        //can't have 0 images
        if self.memory?.images.count == 1{
            return
        }
        
        func removeImage(_:UIViewAnimatingPosition){
            self.memory?.images.remove(at: selectedImage)
            self.displayViews[selectedImage].removeFromSuperview()
            self.displayViews.remove(at: selectedImage)
            if selectedImage == 0{
                self.imageScrollView.subviews.forEach { image in
                    image.center.x -= self.imageScrollView.frame.width
                }
                imageScrollView.contentOffset.x = 0
                imagePageController.currentPage = 0
            }else{
                for i in selectedImage..<(self.displayViews.count){
                    self.displayViews[i].center.x -= self.imageScrollView.frame.width
                }
            }
            self.imageScrollView.contentSize.width -= imageScrollView.frame.width
            if self.displayViews.count == 1{
                self.removeImageButton.isEnabled = false
            }
        }
        
        if selectedImage == 0{
            let anim = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
                self.imageScrollView.contentOffset.x += self.imageScrollView.frame.width
                self.imagePageController.numberOfPages -= 1
            }
            anim.addCompletion(removeImage)
            anim.startAnimation()
        }else{
            let anim = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
                self.imageScrollView.contentOffset.x -= self.imageScrollView.frame.width
                self.imagePageController.numberOfPages -= 1
            }
            anim.addCompletion(removeImage)
            anim.startAnimation()
        }
        
    }
    
    func nameIsUnique()->Bool{
        var returnValue = true
        if self.parentVC?.parentVC?.parentVC?.doc?.memories[memoryIndex!].title == self.titleTextField.text!{
            return true
        }
        self.parentVC?.parentVC?.parentVC?.doc?.memories.forEach({ (mem) in
            if mem.title == self.titleTextField.text{
                returnValue = false
                displayOverlapingNameWarning()
            }
        })
        return returnValue
    }
    
    func displayOverlapingNameWarning(){
        let alert = UIAlertController(title: "Warning", message: "You alredy have a memory using that name, please pick a different name.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
