//
//  ViewController.swift
//  MemeMe
//
//  Created by Lucas Mahe on 15/12/2020.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var keyboardIsUp = false
    var currentTappedTextField: UITextField?
    
    var meme: Meme?
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -3.0
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setting text fields attributes
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .center
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Check for camera accessibility
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        bottomTextField.delegate = self
        topTextField.delegate = self
        
        shareButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        // Reset UI
        imageView.image = nil
        bottomTextField.text = "BOTTOM"
        topTextField.text = "TOP"
    }
    
    
    // MARK - Picture access
    
    @IBAction func galleryClick(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func cameraClick(_ sender: Any) {
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.delegate = self
        present(cameraController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            shareButton.isEnabled = true
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK - Keyboard adjustements
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisapear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // Make sure it triggers only once at a time (Simulator bug)
        // Slide only for bottom text field
        if !keyboardIsUp && currentTappedTextField == bottomTextField {
            view.frame.origin.y -= getKeyboardHeight(notification)
            keyboardIsUp = true
        }

    }
    
    @objc func keyboardWillDisapear(_ notification: Notification) {
        if keyboardIsUp {
            view.frame.origin.y += getKeyboardHeight(notification)
            keyboardIsUp = false
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // MARK - Text fields delegate protocol
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTappedTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    // MARK - Share functionnality
    
    @IBAction func shareClick(_ sender: Any) {
        let memeImage = generateMemedImage()
        let viewController = UIActivityViewController(activityItems: [memeImage], applicationActivities: [])
        viewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                self.saveMeme(memedImage: memeImage)
            }
        }
        present(viewController, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        hideBars(true)
        
        //Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideBars(false)
        
        return memedImage
    }
    
    func hideBars(_ bool: Bool) {
        self.toolBar.isHidden = bool
        self.navBar.isHidden = bool
    }
    
    // MARK - Saving Meme
    
    func saveMeme(memedImage: UIImage) {
    // Create the meme
        meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
    }
    
}
