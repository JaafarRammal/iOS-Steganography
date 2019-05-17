//
//  encryption_controller.swift
//  ISN_Steganography
//
//  Created by Jaafar Rammal on 3/20/18.
//  Copyright © 2018 Jaafar Rammal. All rights reserved.
//

import UIKit
import GoogleMobileAds

class encryption_controller: UIViewController, UITextViewDelegate, GADInterstitialDelegate {
    
    //----------------------------------------------------------------------
    //Define text_to_encode which will be sent through a segue to other controllers to be preserved
    var text_to_encode: String = ""
    
    //Avoid error in case of blank input text with an extra string removed after decoding
    //Potentially, no user will think about encoding this string
    var blank_case: String = "ThisISAN Amazing app TOUT le MONDE aime cacher des SECRETS"
    
    //Define presentation variables
    @IBOutlet var title_1_image: UIImageView!
    @IBOutlet var title_2_image: UIImageView!
    @IBOutlet var preview_image: UIImageView!
    
    //Define view change buttons
    @IBOutlet var decrypt_view_button: UIButton!
    @IBOutlet var encrypt_view_button: UIButton!
    @IBOutlet var image_view_button: UIButton!
    
    //Define encoding process variables
    @IBOutlet var input_text_field: UITextView!
    @IBOutlet var encrypt_button: UIButton!
    @IBOutlet var share_button: UIButton!
    var original_image: UIImage? = nil
    var final_encoded_image: UIImage? = nil
    
    var timer: Timer?
    
    //Define interstitial ad
    //Disabled for ISN Project
    var interstitial: GADInterstitial!
    
    //----------------------------------------------------------------------
    //Encrypt button action
    @IBAction func encrypt_image_or_edit_text(_ sender: Any) {
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            message_to_debugger(message: "Ad wasn't ready #00")
        }
        
        //If the share button is disabled, that means we still did not encode the picture
        if !share_button.isEnabled{
            
            //Resize image to avoid automatic resize after encryption during sharing, which would destroy the information hidden
            let image_to_encode = resizeImage(image: original_image!, targetSize: CGSize.init(width: 1024, height: 1024))
            
            //Try to encode the image. Else, print a message to the debugger
            message_to_debugger(message: "Attenting blank string verification")
            if let encoded_image = Encoder().encode(image: image_to_encode, data: input_text_field.text+blank_case+"\0") {
                self.final_encoded_image = encoded_image
                /*let imageData = UIImagePNGRepresentation(image_to_encode)
                 image_to_encode = UIImage(data: imageData!)!*/
                
            }else {
                message_to_debugger(message: "FAILED TO ENCODE #01")
            }
            
            //Updating view state
            
            //Set the encrypt_button image as "Edit Text" image
            encrypt_button.setImage(#imageLiteral(resourceName: "edit_text_button"), for: UIControl.State.normal)
            encrypt_button.setImage(#imageLiteral(resourceName: "edit_text_button"), for: UIControl.State.highlighted)
            
            //Enable the sharing process
            share_button.isEnabled = true
            
            //Disable text editing, lighter the text color
            input_text_field.isEditable = false
            input_text_field.textColor = UIColor(rgb: 0xC8C8C8)
            
            //Tell the user that their message was sucessfully hidden in the picture
            info_view.isHidden = false
           
            
        //The share button is enabled: user wants to edit the text
        }else{
            
            //Set the encrypt_button image as "Encrypt" image
            encrypt_button.setImage(#imageLiteral(resourceName: "encrypt_button_1"), for: UIControl.State.normal)
            encrypt_button.setImage(#imageLiteral(resourceName: "encrypt_button_2"), for: UIControl.State.highlighted)
            
            //Disable sharing button
            share_button.isEnabled = false
            
            //Allow text editing, darker text color
            input_text_field.isEditable = true
            input_text_field.textColor = UIColor(rgb: 0xABAFB5)
        }
        
    }
    
    //----------------------------------------------------------------------
    //Share button action
    @IBAction func shareImageButton(sender: AnyObject) {
        
        //Make sure the image is in PNG format
        let imageData = final_encoded_image!.pngData()
        
        //Define what we want to share
        let imageToShare = [ UIImage(data: imageData!)! ]
        
        //Create the sharing view
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        //Exclude some activity types from the list (optional, we chose to exclude Facebook posting since it is pointless in terms of our project)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.postToFacebook ]
        
        //Present the sharing view
        self.present(activityViewController, animated: true, completion: nil)
        
        //In case of a directly save button. Was deleted
        //UIImageWriteToSavedPhotosAlbum(final_encoded_image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    //----------------------------------------------------------------------
    //Function to resize an image
    //This function is an open-source code available on the internet and was not created by the developper
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //----------------------------------------------------------------------
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {    }
    
    //Old sharing process
    //Concerved as archive in the code
    /*@IBAction func shareImageButton(_ sender: UIButton) {
     
     
        //COMMON SHARING PROCESS
        // image to share
        let image = final_encoded_image
        
        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
     
     
        //SAVE IMAGE WITH ALERT
        var imageData = UIImageJPEGRepresentation(final_encoded_image!, 0.6)
        var compressedJPGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
        var alert = UIAlertView(title: "Wow",
        message: "Your image has been saved to Photo Library!",
        delegate: nil,
        cancelButtonTitle: "Ok")
        alert.show()
     
    }*/
    
    //----------------------------------------------------------------------
    //End editing action through screen touch
    @IBAction func end_editing(_ sender: Any) {
        
        input_text_field.endEditing(true)
        
    }
    
    //----------------------------------------------------------------------
    //Popover information process
    
    @IBOutlet var info_view: UIView!
    @IBOutlet var info_image: UIImageView!
    @IBOutlet var exit_button: UIButton!
    
    @IBAction func hide_info(_ sender: Any) {
        
        info_view.isHidden = true
        
    }
    
    //----------------------------------------------------------------------
    //Start Application
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.update_view), userInfo: nil, repeats: true)
        
        //------------------------------------------------------------------
        
        //Get screen dimensions to define sizes and positions
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let screenMidX = screenSize.midX
        let screenMidY = screenSize.midY
        var offset = CGFloat.init(20)
        
        //------------------------------------------------------------------
        
        //Test: ca-app-pub-3940256099942544/1033173712
        //Real ID: ca-app-pub-9872946152161101/3658162031
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/1033173712")
        interstitial.delegate = self
        
        let request = GADRequest()
        interstitial.load(request)
        
        //------------------------------------------------------------------
        
        //Initializing scene elements
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            offset = 20
        }
        
        info_view.frame.size = CGSize.init(width: screenWidth, height: screenHeight)
        self.info_view.center = CGPoint.init(x: screenMidX, y: screenMidY)
        info_view.isHidden = true
        
        info_image.layer.cornerRadius = 30.0
        info_image.clipsToBounds = true
        info_image.frame.size.width = screenWidth - 3*offset
        info_image.frame.size.height = info_image.frame.size.width/2601*2985
        self.info_image.center = CGPoint.init(x: screenMidX, y: screenMidY)
        
        exit_button.frame.size.width = screenWidth/16
        exit_button.frame.size.height = exit_button.frame.size.width
        self.exit_button.center = CGPoint.init(x: screenMidX + info_image.frame.size.width/2 - exit_button.frame.size.width/2-1.5*offset , y: screenMidY - info_image.frame.size.height/2 + exit_button.frame.size.width/2 + 1.5*offset)
        
        title_1_image.frame.size.width = screenMidX+offset
        title_1_image.frame.size.height = title_1_image.frame.size.width/1427*117
        self.title_1_image.center = CGPoint.init(x: (screenMidX+offset)/2+offset, y: title_1_image.frame.size.height/2+2.5*offset)
        
        title_2_image.frame.size.width = title_1_image.frame.size.width
        title_2_image.frame.size.height = title_2_image.frame.size.width/1409*218
        self.title_2_image.center = CGPoint.init(x: title_2_image.frame.size.width/2+offset, y: title_1_image.center.y+title_1_image.frame.size.height/2+offset+title_2_image.frame.size.height/2)
        
        preview_image.frame.size.height = title_2_image.center.y-title_1_image.center.y+title_1_image.frame.size.height/2+title_2_image.frame.size.height/2
        preview_image.frame.size.width = preview_image.frame.size.height
        self.preview_image.center = CGPoint.init(x: screenWidth-offset-preview_image.frame.size.width/2, y: title_1_image.center.y+(title_2_image.center.y-title_1_image.center.y)/2)
        preview_image.layer.cornerRadius = 15
        preview_image.clipsToBounds = true
        preview_image.image = original_image
        
        encrypt_view_button.isEnabled = false
        encrypt_view_button.setImage(#imageLiteral(resourceName: "encrypt_view_active"), for: UIControl.State.disabled)
        encrypt_view_button.frame.size.width = screenWidth/3
        encrypt_view_button.frame.size.height = (screenWidth/3)/251*137
        self.encrypt_view_button.center = CGPoint.init(x: encrypt_view_button.frame.size.width*1.5, y: screenHeight-(encrypt_view_button.frame.size.height/2))
        
        
        decrypt_view_button.isEnabled = true
        decrypt_view_button.setImage(#imageLiteral(resourceName: "access_decrypt_view"), for: UIControl.State.normal)
        decrypt_view_button.frame.size.width = screenWidth/3
        decrypt_view_button.frame.size.height = (screenWidth/3)/251*137
        self.decrypt_view_button.center = CGPoint.init(x: decrypt_view_button.frame.size.width*2.5, y: screenHeight-(decrypt_view_button.frame.size.height/2))
        
        
        image_view_button.isEnabled = true
        image_view_button.setImage(#imageLiteral(resourceName: "access_image_view"), for: UIControl.State.normal)
        image_view_button.frame.size.width = screenWidth/3
        image_view_button.frame.size.height = (screenWidth/3)/251*137
        self.image_view_button.center = CGPoint.init(x: image_view_button.frame.size.width/2, y: screenHeight-(image_view_button.frame.size.height/2))
        
        share_button.frame.size.width = screenWidth-2*offset
        share_button.frame.size.height = share_button.frame.size.width/2608*391
        self.share_button.center = CGPoint.init(x: screenMidX, y: encrypt_view_button.center.y-encrypt_view_button.frame.size.height/2-share_button.frame.size.height/2-offset)
        share_button.setImage(#imageLiteral(resourceName: "share_button_2"), for: UIControl.State.normal)
        share_button.setImage(#imageLiteral(resourceName: "share_button_1"), for: UIControl.State.highlighted)
        share_button.isEnabled = false
        
        encrypt_button.frame.size.width = screenWidth-2*offset
        encrypt_button.frame.size.height = encrypt_button.frame.size.width/2608*391
        self.encrypt_button.center = CGPoint.init(x: screenMidX, y: share_button.center.y-share_button.frame.size.height/2-offset-encrypt_button.frame.size.height/2)
        encrypt_button.setImage(#imageLiteral(resourceName: "encrypt_button_1"), for: UIControl.State.normal)
        encrypt_button.setImage(#imageLiteral(resourceName: "encrypt_button_2"), for: UIControl.State.highlighted)
        
        var margin = CGFloat.init(20)
        var bound = CGFloat.init(15)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            input_text_field.font = UIFont(name: (input_text_field.font?.fontName)!, size: 45)
            margin = 35
            bound = 30
        }
        input_text_field.layer.cornerRadius = bound
        input_text_field.clipsToBounds = true
        input_text_field.textContainerInset = UIEdgeInsets(top:margin, left:margin , bottom:margin, right:margin)
        input_text_field.frame.size.width = screenWidth-2*offset
        input_text_field.frame.size.width = screenWidth-2*offset
        input_text_field.frame.size.height = screenHeight-encrypt_view_button.frame.size.height-share_button.frame.size.height-encrypt_button.frame.size.height-title_1_image.frame.size.height-title_2_image.frame.size.height-offset*7
        self.input_text_field.center = CGPoint.init(x: screenMidX, y: title_2_image.center.y+title_2_image.frame.size.height/2+offset+input_text_field.frame.size.height/2)
        input_text_field.placeholder = ""
        
        input_text_field.textColor = UIColor(rgb:0xABAFB5)
        
        if text_to_encode != ""{
            input_text_field.text = text_to_encode
        }
        
        if original_image == nil{
            message_to_debugger(message: "NIL IMAGE IMPORTED THERE IS AN ERROR")
        }
        
        //------------------------------------------------------------------
        
        
    }
    
    //----------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------------------------------------------------------------------
    //Parsing the different variales between the controllers on segue action
    //This is done since the controller is re-initialized each time it is closed/opened
    //These variables include the original image imported and the text to encode
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        text_to_encode = input_text_field.text
        
        if let decryption_controller = segue.destination as? decryption_controller {
            decryption_controller.original_image = self.original_image
            decryption_controller.text_to_encode = self.text_to_encode
        }
        
        if let image_selection_controller = segue.destination as? image_selection_controller {
            image_selection_controller.original_image = self.original_image
            image_selection_controller.text_to_encode = self.text_to_encode
        }
    }
    
    //----------------------------------------------------------------------
    //Print debbuger message with class name
    private func message_to_debugger(message: String){
    
        print(self.description + ": " + message)
        
    }
    
    //----------------------------------------------------------------------
    //Function to uptdate the view during process
    //Called through a timer
    @objc func update_view(){
        
        if input_text_field.text == "" {
            input_text_field.placeholder = "Enter Text"
        }
        
    }
    
    //----------------------------------------------------------------------
    
}

//--------------------------------------------------------------------------
//Extension for the placeholder
//This extension is an open-source code available on the internet and was not created by the developper

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.characters.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainerInset.right + 5
            let labelY = self.textContainerInset.top
            let labelWidth = self.frame.width
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor(rgb: 0xABAFB5)
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.characters.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}

//--------------------------------------------------------------------------

