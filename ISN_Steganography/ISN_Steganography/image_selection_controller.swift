//
//  image_selection_controller.swift
//  ISN_Steganography
//
//  Created by Jaafar Rammal on 3/20/18.
//  Copyright © 2018 Jaafar Rammal. All rights reserved.
//

import UIKit
import GoogleMobileAds

@IBDesignable

class image_selection_controller: UIViewController, UIPopoverPresentationControllerDelegate, GADRewardBasedVideoAdDelegate {
    
    //----------------------------------------------------------------------
    //Video Ad function for implementation
    //Not used in the ISN Project
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        
    }
    
    //----------------------------------------------------------------------
    //Initializing the text to encode, which changes in case of a segue from the encryption controller
    var text_to_encode: String = ""
    
    //Define presentation variables
    @IBOutlet var title_1_image: UIImageView!
    @IBOutlet var intro_image: UIImageView!
    @IBOutlet var info_button: UIButton!
    
    //Define view change buttons
    @IBOutlet var decrypt_view_button: UIButton!
    @IBOutlet var encrypt_view_button: UIButton!
    @IBOutlet var image_view_button: UIButton!
    
    //Define image process variables
    @IBOutlet var image_preview: UIImageView!
    @IBOutlet var add_image_button: UIButton!
    @IBOutlet var camera_roll_button: UIButton!
    
    var original_image: UIImage? = nil
    let imagePicker = UIImagePickerController()
    var timer: Timer?

    //----------------------------------------------------------------------
    //Link the open library function to a button action
    @IBAction func open_library(_ sender: Any) {
        
        openPhotoLibrary()
        
    }
    
    //Link the open camera function to a button action
    @IBAction func open_camera(_ sender: Any) {
        
        openCamera()
        
    }
    
    //----------------------------------------------------------------------
    //Popover information process
    @IBOutlet var info_view: UIView!
    @IBOutlet var info_image: UIImageView!
    @IBOutlet var exit_button: UIButton!
   
    //Show the popover view
    @IBAction func popover_info(_ sender: Any) {
        
        info_view.isHidden = false
        
    }
    
    //Hide the popover view
    @IBAction func hide_info(_ sender: Any) {
        
        info_view.isHidden = true
        
    }
    
    //----------------------------------------------------------------------
    //Ad variables
    //Disabled for ISN Project
    //var ad_has_shown: Bool = false
    
    
    
    //Start application
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Test ID: ca-app-pub-3940256099942544/2247696110
        //Real ID: ca-app-pub-9872946152161101/7451789580
        
        //Initialize Ad
        //Disabled for ISN Project
        
        /*GADRewardBasedVideoAd.sharedInstance().delegate = self
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: "ca-app-pub-3940256099942544/2247696110")*/
        
        //Timer to update the view every 0.0001 seconds
        timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.update_view), userInfo: nil, repeats: true)
        
        //----------------------------------------------------------------------
        
        //Get screen different dimensions to define sizes and positions
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let screenMidX = screenSize.midX
        let screenMidY = screenSize.midY
        var offset = CGFloat.init(20)

        //----------------------------------------------------------------------
        
        //Initializing scene elements
        
        //Defining offset, the pixel distance from screen edges, in case of the device nature
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            offset = 20
        }
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            offset = 20
        }
  
        //Sizes and positions are mathematically deifnied proportionnally to the screen dimensions
        //Size: First is defined the width, then the height proportionally to the width
        //Position: the center is defined in respect to other elements and screen dimensions
        //Buttons have an image for each state (if available): normal, disabled, highlighted
        //Corner Radius and Clips To Bounds smoothes the rectangles on the edges
        
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
        
        
        info_button.frame.size.width = title_1_image.frame.size.height
        info_button.frame.size.height = info_button.frame.size.width
        self.info_button.center = CGPoint.init(x: screenWidth-offset-info_button.frame.size.width/2, y: title_1_image.center.y)
        info_button.setImage(#imageLiteral(resourceName: "info_1"), for: UIControl.State.normal)
        info_button.setImage(#imageLiteral(resourceName: "info_2"), for: UIControl.State.highlighted)
        
        
        intro_image.frame.size.width = screenWidth-2*offset-info_button.frame.size.width
        intro_image.frame.size.height = intro_image.frame.size.width/2259*991
        self.intro_image.center = CGPoint.init(x: screenMidX-info_button.frame.size.width/2, y: screenMidY-intro_image.frame.size.height/2)
        
        
        encrypt_view_button.isEnabled = false
        encrypt_view_button.setImage(#imageLiteral(resourceName: "access_encrypt_view"), for: UIControl.State.normal)
        encrypt_view_button.frame.size.width = screenWidth/3
        encrypt_view_button.frame.size.height = (screenWidth/3)/251*137
        self.encrypt_view_button.center = CGPoint.init(x: encrypt_view_button.frame.size.width*1.5, y: screenHeight-(encrypt_view_button.frame.size.height/2))
  
        
        decrypt_view_button.isEnabled = false
        decrypt_view_button.setImage(#imageLiteral(resourceName: "access_decrypt_view"), for: UIControl.State.normal)
        decrypt_view_button.frame.size.width = screenWidth/3
        decrypt_view_button.frame.size.height = (screenWidth/3)/251*137
        self.decrypt_view_button.center = CGPoint.init(x: decrypt_view_button.frame.size.width*2.5, y: screenHeight-(decrypt_view_button.frame.size.height/2))
        
        
        image_view_button.isEnabled = false
        image_view_button.setImage(#imageLiteral(resourceName: "image_view_active"), for: UIControl.State.disabled)
        image_view_button.setImage(#imageLiteral(resourceName: "image_view_active"), for: UIControl.State.normal)
        image_view_button.frame.size.width = screenWidth/3
        image_view_button.frame.size.height = (screenWidth/3)/251*137
        self.image_view_button.center = CGPoint.init(x: image_view_button.frame.size.width/2, y: screenHeight-(image_view_button.frame.size.height/2))

        
        add_image_button.setImage(#imageLiteral(resourceName: "image_button_1"), for: UIControl.State.normal)
        add_image_button.setImage(#imageLiteral(resourceName: "image_button_2"), for: UIControl.State.highlighted)
        add_image_button.frame.size.width = screenWidth-2*offset
        add_image_button.frame.size.height = add_image_button.frame.size.width/2607*392
        self.add_image_button.center = CGPoint.init(x: screenMidX, y: decrypt_view_button.center.y-decrypt_view_button.frame.size.height/2-offset-add_image_button.frame.size.height/2)
        
        camera_roll_button.setImage(#imageLiteral(resourceName: "camera_2"), for: UIControl.State.normal)
        camera_roll_button.setImage(#imageLiteral(resourceName: "camera_1"), for: UIControl.State.highlighted)
        camera_roll_button.frame.size.width = screenWidth-2*offset
        camera_roll_button.frame.size.height = camera_roll_button.frame.size.width/2608*392
        self.camera_roll_button.center = CGPoint.init(x: screenMidX, y: add_image_button.center.y-offset-camera_roll_button.frame.size.height)
        
        image_preview.frame.size.width = screenWidth-2*offset
        image_preview.frame.size.height = image_preview.frame.size.width
        self.image_preview.center = CGPoint.init(x: screenMidX, y: title_1_image.center.y+(camera_roll_button.center.y-title_1_image.center.y)/2)
        image_preview.layer.cornerRadius = 30.0
        image_preview.clipsToBounds = true
        image_preview.isHidden = true
        
        //------------------------------------------------------------------
        
    }

    //----------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Null
        
    }

    //----------------------------------------------------------------------
    //Function to uptdate the view during process
    //Called through a timer
    @objc func update_view(){
        
        //Update button states
        
        //If there is no image, user can't access to other views
        if self.original_image == nil{
            encrypt_view_button.isEnabled = false
            decrypt_view_button.isEnabled = false
            image_preview.isHidden = true
            intro_image.isHidden = false
        }
            
            //If there is an image, user can access to other views
        else{
            encrypt_view_button.isEnabled = true
            decrypt_view_button.isEnabled = true
            intro_image.isHidden = true
            image_preview.isHidden = false
            image_preview.image = original_image
        }
    
        //Video Ad of 5 seconds displayed once
        //Disbaled for the ISN Project
        /*
         if GADRewardBasedVideoAd.sharedInstance().isReady == true {
         print("Loading Ad in process")
         if ad_has_shown == false{
         GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
         }
         
         }*/
        
        
    }
    
    //----------------------------------------------------------------------
    //Parsing the different variales between the controllers on segue action
    //This is done since the controller is re-initialized each time it is closed/opened
    //These variables include the original image imported and the text to encode
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //If the destination is the encryption_controller
        if let encryption_controller = segue.destination as? encryption_controller {
            encryption_controller.original_image = self.original_image
            encryption_controller.text_to_encode = self.text_to_encode
        }
        //If the destination is the decryption_controller
        if let decryption_controller = segue.destination as? decryption_controller {
            decryption_controller.original_image = self.original_image
            decryption_controller.text_to_encode = self.text_to_encode
        }
    }
    
    //----------------------------------------------------------------------
    //Print debbuger message with class name
    private func message_to_debugger(message: String){
        
        print(self.description + ": " + message)
        
    }
    
    //----------------------------------------------------------------------
}

//--------------------------------------------------------------------------

//Extension to control the image picking between camera and photo library
//This extension is an open-source code available on the internet and was not created by the developper
//Messages to the debugger were added to follow the code in case of errors

extension image_selection_controller: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        defer {
            picker.dismiss(animated: true)
        }
        
        print(info)
        
        // get the image
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            return
        }
        
        original_image = image
        
    }
    
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            message_to_debugger(message: "Camera not supported by this device #00")
            return
        }
        
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
        }
        
        message_to_debugger(message: "User successfully canceled action #01")
    }
    
    func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            message_to_debugger(message: "Can't open photo library #02")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
}

//--------------------------------------------------------------------------

//APP ADS ID: ca-app-pub-9872946152161101~7975244208

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
