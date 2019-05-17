package steganography;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.InputMismatchException;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;

/**
 * @author jaafarrammal & samiharakeh
 */
public class Main {
    
    // Scanner Java pour obtenir les entrées de l'utilisateur
    static Scanner user_input = new Scanner(System.in);
    
    // Les caractères de reconnaissance ajoutés au début et à la fin du texte
    static char begin_recognition_char = '<';
    static char end_recognition_char = '>';
    
    
    //Hide text function
    //Inputs: the text to hide and the image to hide the text in
    //Outputs: none
    //Special void: saves the new image with a hidden text
    public static void hide_text(BufferedImage original_image, String text_to_hide) {
        
        //Define an integer that will represent the ASCII code (8-bits form) of a specific character in the text
	int current_ascii;
        
        //Two pixel_x and pixel_y variables to follow our position in the image (at what pixel we are)
	int pixel_x = 0;				
	int pixel_y = 0;
        
        //Add a small recognition char to the end of our text (that char should therefore not be used in the encrypted text)
        text_to_hide = begin_recognition_char + text_to_hide + end_recognition_char;
        
        //This loop will be executed "number of chars" times
	for(int i = 0; i < text_to_hide.length(); i++) {
            
            //Get the i-char ASCII code
            current_ascii = (int) text_to_hide.charAt(i);
            
            //From 0 to 7 (aka j<8) since our ASCII code representation contains 8 digits
            for(int j = 0; j < 8; j++) {
                
                //This "&" (bitwise AND operation) between two integers expression will return either 1 or 0: our 1 in hex is 0x00000001. If the ASCII code's last digit is 1, "current bit" will take the value of 1, and same goes for 0
                //Therefore, 0b....00101101 & 0x00000001 returns 0x00000001 (=1)
                int current_ascii_digit = current_ascii & 0x00000001;
                
                //The last digit is either 1 or 0. Use an if to execute separate codes in each case
                
                //Case the digit is 1
                if(current_ascii_digit == 1) {	
                 
                    //If we did not reach the end of the current line (x<image.width), we can change this pixel
                    if(pixel_x < original_image.getWidth()) {
                        
                        //Change the current pixel RGB encoding: indicate the pixel's positions and writes 1 to the last bit of the pixel through an "|" (bitwise inclusive OR operation) with 0x00000001 (or simply 1)
                        //The comparaison process is simple: if either or both contains 1 for a certain digit position, expression returns 1 for this digit. Therefore, 0b10010100 | 0b00101101 returns 0b10111101
                        original_image.setRGB(pixel_x, pixel_y, original_image.getRGB(pixel_x, pixel_y) | 0x00000001);
                        
                        //Go to next pixel
                        pixel_x++;
                    }
			
                    //We reached the end of the line
                    else {
                        
                        //Return to the beginning of the line
                        pixel_x = 0;
                        
                        //Move one line down
			pixel_y++;
                        
                        //Same process as above
                        original_image.setRGB(pixel_x, pixel_y, original_image.getRGB(pixel_x, pixel_y) | 0x00000001);
                    }
		} 
                
                //Case the digit is 0
                else {
                    
                    //If we did not reach the end of the current line (x<image.width), we can change this pixel
                    if(pixel_x < original_image.getWidth()) {
                        
                        //Change the current pixel RGB encoding: indicate the pixel's positions and writes 0 to the last bit of the pixel through an "&" (bitwise AND operation) with 0xFFFFFFFE (or simply 0b11111110)
                        //Why an AND? Since we compare 1s and 0s, we are using the opposite process here: for exemple, 0b....10011011 | 0b11111110 returns 0b....10011010 (if both have 1 for a specific position it takes the value of 1, else it takes 0!)
                        original_image.setRGB(pixel_x, pixel_y, original_image.getRGB(pixel_x, pixel_y) & 0xFFFFFFFE);
                        
                        //Go to next pixel
                        pixel_x++;
                    }
                    
                    //We reached the end of the line
                    else {
                        
                        //Return to the beginning of the line
                        pixel_x = 0;
                        
                        //Move one line down
                        pixel_y++;
                        
                        //Same process as above
                        original_image.setRGB(pixel_x, pixel_y, original_image.getRGB(pixel_x, pixel_y) & 0xFFFFFFFE);	// store the bit which is 0 into a pixel's last digit
                    }
                }
                    
                //Shift our ASCII 8 digits form one degree to the right, therefore comparing in the next loop-turn the second digit from our ASCII code
                current_ascii = current_ascii >> 1;
		}			
	}
		
		//Save the new processed image to a specific directory. This method requires an error try/catch
		try {
                        //Ask the suer for the directory
                        System.out.println("Enter the directory where you would like to save your image:");
                        
                        //Create directory
			File directory = new File(user_input.next() + "/hidden_message.png");
                        
                        //Save the image
			ImageIO.write(original_image, "png", directory);	
		} catch (IOException e) {
			
		}		
		
	}
	
    //Retrieves the hidden message from the image
    //Inputs: the image with a hidden message
    //Output: the message
    public static void retrieve_text(BufferedImage image) {
        
        //Two pixel_x and pixel_y variables to follow our position in the image (at what pixel we are)
	int pixel_x = 0;
	int pixel_y = 0;
        
        //Variable to store the current bit during the extraction process
	int current_bit;
        
        //Maximum length of chars: image.dimensions/8 since each character is hidden in 8 pixels
        int length = image.getWidth()*image.getHeight()/8;
        
        //Char holder
        char char_holder = '0';
	
        OUTER:
        //Repeat the search process the maximum number of chars time
        for(int i = 0; i < length; i++) {
            
            //Create our ASCII 8-bits for the char encoding
            int ascii_8_bits = 0;
            
            //Get the 8 bits of the char through this expression, which repeats 8 times
            for(int j = 0; j < 8; j++) {
                
                //If we did not reach the end of the current line (x<image.width), we can extract a bit from this pixel
		if(pixel_x < image.getWidth()) {
                    
                    //Get the last digit (less significant bit) of the pixel through a bitwise AND operation (&)
                    //Exemple: 0x10110101 & 0x00000001 returns 1
                    current_bit = image.getRGB(pixel_x, pixel_y) & 0x00000001;
                    
                    //Go to the next pixel
                    pixel_x++;
		}
                
                //We reached the end of the line
		else {
                    
                    //Return to the beginning of the line
                    pixel_x = 0;
                    
                    //Move one line down
                    pixel_y++;
                    
                    //Same process as above
                    current_bit = image.getRGB(pixel_x, pixel_y) & 0x00000001;
		}
		
		//Store the bit in the ASCII 8-bits variable
                
                //If the value to add is 1
		if(current_bit == 1) {	
                    
                    //Shift our ASCII-8bits one degree to the right
                    ascii_8_bits = ascii_8_bits >> 1;	
                    
                    //Add the digit 1 to the ASCII-8bits variable through a bitwise inclusive OR operation (|) with 0x80 (0b10000000)
                    //Exemple: 0x00000000|0x80 gives 0b10000000. We shift then 0b01000000|0x80 gives 0b11000000 etc...
                    ascii_8_bits = ascii_8_bits | 0x80;
		}
                
                //If the value to add is 0
		else {	
                    
                    //Simple shift our ASCII-8bits one degree to the right
                    ascii_8_bits = ascii_8_bits >> 1;
		}				
            }
            
            //Create the char from the ASCII 8-bits number
            char_holder = (char) ascii_8_bits;
            
            //If we are still at the first char or not
            if(i!=0){

                //If we still did not reach the end recognition char, print the current char and continue the process normally
                if(char_holder != end_recognition_char){
                    System.out.print(char_holder);
                }
            
                //We reached the end recognition char. We print an emtpy line and end the process
                else{
                    System.out.println();
                    break;
                }
            }
            
            //If we are still at the first char, check if it corresponds to the begin recognition char
            else{
                
                //If not, the image does not contain a message: exit from loop
                if(char_holder != begin_recognition_char){
                    System.out.println("Your image does not contain a hidden message :/");
                    break;
                }
                else{
                    
                    //It contains, continue process
                    System.out.print("The hidden text is: ");
                }
            }
            
	}
    }
    
    //Main console loop
    public static void main(String[] args) {
    
        //Command variable
        int command = 0;
        
        //While loop that breaks at the default inside switch state
        OUTER:
        while (true) {
            
            //Check the validity of the command
            while(true){
                
                //Print commands
                System.out.println("Commands:\n1-Hide a message in an image\n2-Retrieve a message from an image\n3-Exit\n");
                
                //Catch non-valid type input (!= int)
                try{
                    command = user_input.nextInt();
                }
                catch(InputMismatchException e){
                    
                    //Warn user
                    System.out.println("Please enter a valid command");
                    
                    //Clear Scanner
                    String tt = user_input.nextLine();
                    
                    //Return to beginning
                    continue;
                }
                
                //If the command valid or not
                if(command!=1 && command!=2 && command !=3){
                    
                    //Warn user
                    System.out.println("Please enter a valid command");
                    
                }else{
                    
                    //The command is valid: exit from that second while
                    break;
                }
            }
            
            //Switch on command values
            switch (command) {
                
                //Case the user wants to hide a message
                case 1:
                    {
                        //Ask for the text. Called twice to clean the scanner
                        System.out.println("\nEnter the message you wish to hide. Please do not user the characters '<' and '>':");
                        
                        //Clear Scanner
                        String text = user_input.nextLine();
                        
                        //Take the message
                        text = user_input.nextLine();
                        
                        //Make sure the user knows what is the message he entered
                        System.out.println("Your text is: "+text);
                        
                        //Ask for the image directory
                        System.out.println("Enter the directory of the image:");
                        
                        //Create path
                        File path_original_image = new File(user_input.next());
                        
                        //Load the image
                        BufferedImage original_image  = null;
                        try {
                            original_image = ImageIO.read(path_original_image);
                        } catch (IOException ex) {
                            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
                        }       //Hide the text
                        
                        //Hide the message
                        hide_text(original_image,text);
                        
                        //Exit from switch
                        break;
                    }
                    
                //Case the user wants to retrieve a message
                case 2:
                    {
                        //Ask for the image directory
                        System.out.println("Enter the directory of the image:");
                        
                        //Create path
                        File path_original_image = new File(user_input.next());
                        
                        //Load the image
                        BufferedImage original_image  = null;
                        try {
                            original_image = ImageIO.read(path_original_image);
                        } catch (IOException ex) {
                            Logger.getLogger(Main.class.getName()).log(Level.SEVERE, null, ex);
                        }

                        //Retrieve message
                        retrieve_text(original_image);
                        
                        //Exit from switch
                        break;
                    }
                    
                //Loads when the command is 3 (not 1 nor 2)
                default:
                    
                    //Break outer while loop (exit program)
                    break OUTER;
            }
        }
        
        
    }
    
}