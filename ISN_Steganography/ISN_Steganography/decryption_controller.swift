//
//  decryption_controller.swift
//  ISN_Steganography
//
//  Created by Jaafar Rammal on 3/20/18.
//  Copyright © 2018 Jaafar Rammal. All rights reserved.
//

import UIKit

class decryption_controller: UIViewController {
    
    //----------------------------------------------------------------------
    //Parsing variables
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
    
    //Define decoding process variables
    @IBOutlet var output_text_field: UITextView!
    @IBOutlet var decrypt_button: UIButton!
    @IBOutlet var share_button: UIButton!
    var original_image: UIImage? = nil
    
    var decoded_text: String = ""
    
    var timer: Timer?
    
    //----------------------------------------------------------------------
    //Decrypt image button action
    @IBAction func decrypt_image(_ sender: Any) {
        
        if original_image != nil {

            if var data = Decoder().decode(image: original_image!){
                message_to_debugger(message: "Attenting blank string verification")
                data = data.replacingOccurrences(of: blank_case, with: "")
                output_text_field.text = data
                decoded_text = data
            } else {
                message_to_debugger(message: "FAILED TO DECODE")
            }
        }
        info_view.isHidden = false
        share_button.isEnabled = true
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
    //Share text button
    @IBAction func shareTextButton(_ sender: UIButton) {
        
        // text to share
        let text = decoded_text
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    //----------------------------------------------------------------------
    //Start application
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        timer = Timer.init()
        
        //------------------------------------------------------------------
        //Get screen dimensions to define sizes and positions
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let screenMidX = screenSize.midX
        let screenMidY = screenSize.midY
        var offset = CGFloat.init(20)
        
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
        
        //Initializing scene elements
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            offset = 20
        }
        
        title_1_image.frame.size.width = screenMidX+offset
        title_1_image.frame.size.height = title_1_image.frame.size.width/1427*117
        self.title_1_image.center = CGPoint.init(x: (screenMidX+offset)/2+offset, y: title_1_image.frame.size.height/2+2.5*offset)
        
        title_2_image.frame.size.width = title_1_image.frame.size.width
        title_2_image.frame.size.height = title_2_image.frame.size.width/1407*218
        self.title_2_image.center = CGPoint.init(x: title_2_image.frame.size.width/2+offset, y: title_1_image.center.y+title_1_image.frame.size.height/2+offset+title_2_image.frame.size.height/2)
        
        preview_image.frame.size.height = title_2_image.center.y-title_1_image.center.y+title_1_image.frame.size.height/2+title_2_image.frame.size.height/2
        preview_image.frame.size.width = preview_image.frame.size.height
        self.preview_image.center = CGPoint.init(x: screenWidth-offset-preview_image.frame.size.width/2, y: title_1_image.center.y+(title_2_image.center.y-title_1_image.center.y)/2)
        preview_image.layer.cornerRadius = 15
        preview_image.clipsToBounds = true
        preview_image.image = original_image
        
        encrypt_view_button.isEnabled = true
        encrypt_view_button.setImage(#imageLiteral(resourceName: "access_encrypt_view"), for: UIControl.State.normal)
        encrypt_view_button.frame.size.width = screenWidth/3
        encrypt_view_button.frame.size.height = (screenWidth/3)/251*137
        self.encrypt_view_button.center = CGPoint.init(x: encrypt_view_button.frame.size.width*1.5, y: screenHeight-(encrypt_view_button.frame.size.height/2))
        
        
        decrypt_view_button.isEnabled = false
        decrypt_view_button.setImage(#imageLiteral(resourceName: "decrypt_view_active"), for: UIControl.State.disabled)
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

        decrypt_button.frame.size.width = screenWidth-2*offset
        decrypt_button.frame.size.height = decrypt_button.frame.size.width/2608*391
        decrypt_button.setImage(#imageLiteral(resourceName: "decrypt_button_1"), for: UIControl.State.normal)
        decrypt_button.setImage(#imageLiteral(resourceName: "decrypt_button_2"), for: UIControl.State.highlighted)
        self.decrypt_button.center = CGPoint.init(x:screenMidX, y:title_2_image.center.y+title_2_image.frame.size.height/2+offset+decrypt_button.frame.size.height/2)
        
        var margin = CGFloat.init(20)
        var bound = CGFloat.init(15)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            output_text_field.font = UIFont(name: (output_text_field.font?.fontName)!, size: 45)
            margin = 35
            bound = 30
        }
        output_text_field.layer.cornerRadius = bound
        output_text_field.clipsToBounds = true
        output_text_field.textContainerInset = UIEdgeInsets(top:margin, left:margin , bottom:margin, right:margin)
        output_text_field.frame.size.width = screenWidth-2*offset
        output_text_field.frame.size.width = screenWidth-2*offset
        output_text_field.frame.size.height = screenHeight-encrypt_view_button.frame.size.height-share_button.frame.size.height-decrypt_button.frame.size.height-title_1_image.frame.size.height-title_2_image.frame.size.height-offset*7
        self.output_text_field.center = CGPoint.init(x: screenMidX, y: (share_button.center.y+decrypt_button.center.y)/2)
        output_text_field.text = "Output Text"
        
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
        
        if let encryption_controller = segue.destination as? encryption_controller {
            encryption_controller.original_image = self.original_image
            encryption_controller.text_to_encode = self.text_to_encode
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
    
    
}
