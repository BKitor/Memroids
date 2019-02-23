//
//  MemoryEditingViewController2.swift
//  Memroids
//
//  Created by Paul Kitor on 2018-07-31.
//  Copyright © 2018 bkitor. All rights reserved.
//

import UIKit

class MemoryEditingViewController2: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var memory:MemoryDataObject?
    var displayViews:[UIImageView]=[]
    var parentVC:LandingPageViewController?
    
    @IBOutlet weak var RemoveImageButton: UIButton!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imagePageController: UIPageControl!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reminderDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.memory?.title
        self.titleTextField.text = memory?.title
        setUpScrollView()
        self.RemoveImageButton.isEnabled = false
        
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        self.navigationItem.setRightBarButton(saveButton, animated: false)

        // Do any additional setup after loading the view.
    }
    
    @objc func save(){
        //check for duplicate name
        if !nameIsUnique(){
            return
        }
        
        self.memory?.title = titleTextField.text!
        self.memory?.subtitle = detailTextView.text
        self.memory?.reminderDate = reminderDatePicker.date
        
        mainVC?.doc?.memories.append(self.memory!)
        mainVC?.doc?.save(to: (mainVC?.fileURL)!, for: .forOverwriting, completionHandler: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = imageScrollView.contentOffset.x / imageScrollView.frame.width
        imagePageController.currentPage = Int(pageNumber)
    }
    
    func setUpScrollView(){
        self.view.layoutIfNeeded()
        imageScrollView.delegate = self
        imageScrollView.showsHorizontalScrollIndicator = false
        let imFrame = CGRect(x: 0, y: 0, width: imageScrollView.frame.width, height: imageScrollView.frame.height - 20 - (navigationController?.navigationBar.frame.height)!)
        imageScrollView.contentSize = imFrame.size
        let imView = UIImageView(image: memory?.images[0])
        imView.frame = imFrame
        imView.contentMode = .scaleAspectFit
        self.displayViews.append(imView)
        imageScrollView.addSubview(self.displayViews[0])
    }

    //remember to reset page controller
    @IBAction func removeImage_touchUpInside(_ sender: Any) {
        let selectedImage = Int(self.imageScrollView.contentOffset.x/self.imageScrollView.frame.width)
        
        if self.memory?.images.count == 1{
            return
        }
        
        //completion function, called after the animation is done
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
                self.RemoveImageButton.isEnabled = false
            }
        }
        
        //if statemtent to deal with the animation
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
    
    @IBAction func addImage_TouchUpInside(_ sender: Any) {
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
        self.imageScrollView.contentSize.width += self.imageScrollView.frame.width
        
        //add new Image to scroll View
        let imageFrame = CGRect(x: CGFloat((self.memory?.images.count)! - 1) * imageScrollView.frame.width, y: 0, width: imageScrollView.frame.width, height: imageScrollView.frame.height)
        let imView = UIImageView(image: image)
        imView.contentMode = .scaleAspectFit
        imView.frame = imageFrame
        self.displayViews.append((imView))
        imageScrollView.addSubview(self.displayViews.last!)
        imagePageController.numberOfPages += 1
        let anim = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
            let dest = self.imageScrollView.contentSize.width - self.imageScrollView.frame.width
            self.imageScrollView.contentOffset.x = dest
            let pageNumber = self.imageScrollView.contentOffset.x / self.imageScrollView.frame.width
            self.imagePageController.currentPage = Int(pageNumber)
        }
        self.RemoveImageButton.isEnabled = true
        picker.dismiss(animated: true) {
            anim.startAnimation()
        }
    }
    
    func displayOverlapingNameWarning(){
        let alert = UIAlertController(title: "Warning", message: "You alredy have a memory using that name, please pick a different name.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func setMemory(_ mem:MemoryDataObject){
        self.memory = mem
    }
    
    func nameIsUnique()->Bool{
        var returnValue = true
        self.parentVC?.doc?.memories.forEach({ (mem) in
            if self.titleTextField.text == mem.title{
                self.displayOverlapingNameWarning()
                returnValue = false
            }
        })
        return returnValue
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
