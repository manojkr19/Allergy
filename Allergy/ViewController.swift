//
//  ViewController.swift
//  Allergy
//
//  Created by Manoj Narayanan on 9/30/17.
//  Copyright © 2017 Manoj Narayanan. All rights reserved.
//

import UIKit
import BarcodeScanner
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, BarcodeScannerCodeDelegate, BarcodeScannerDismissalDelegate {
    
    var scanned = false
    
    @IBOutlet weak var txtDisplay: UITextView!
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        
        if !scanned {
            print(code)
            scanned = true
            let urlUPC = "https://api.nal.usda.gov/ndb/search/?format=json&q=\(code)&api_key=O7jIFgfkCPVMSYKRDnSrIjkwcoaQVBqirPxJm4rf"
            Alamofire.request(urlUPC, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = "\(JSON(value)["list"]["item"][0]["ndbno"])"
                    Alamofire.request("https://api.nal.usda.gov/ndb/reports/?ndbno=\(json)&type=b&format=json&api_key=O7jIFgfkCPVMSYKRDnSrIjkwcoaQVBqirPxJm4rf", method: .get).validate().responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)["report"]["food"]["ing"]["desc"]
                            self.txtDisplay.text = "\(json)"
                            controller.dismiss(animated: true, completion: nil)
                        case .failure(let error):
                            print(error)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
            controller.reset()
        }
        
    }
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func presentBarcode(_ sender: Any) {
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.dismissalDelegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let searchString = ["this", "sea"]
        let baseString = txtDisplay.text!
        
        let attributed = NSMutableAttributedString(string: baseString)
        if baseString != "" {
            attributed.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "GothamRounded-Medium", size: 26.0), range: NSRange(location: 0, length: baseString.count-1))
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            attributed.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: baseString.count-1))
            for i in searchString {
                do {
                    let regex = try NSRegularExpression(pattern: i, options: .caseInsensitive)
                    for match in regex.matches(in: baseString, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: baseString.utf16.count)) as [NSTextCheckingResult] {
                        attributed.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor(red: 62/255, green: 146/255, blue: 204/255, alpha: 1.0), range: match.range)
                        //                    attributed.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: match.range)
                    }
                }
                catch _ {
                    print("Oh no!")
                }
            }
            
            txtDisplay.attributedText = attributed
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

