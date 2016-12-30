//
//  ViewController.swift
//  test-ccp-swiftJavascriptBridge
//
//  Created by pair on 12/30/16.
//  Copyright © 2016 pair. All rights reserved.
//

import UIKit
import SwiftJavascriptBridge
import Foundation

class ViewController: UIViewController {

    // MARK: - Constants.
    fileprivate let kNibName: String = "SwiftJavascriptViewController"
    fileprivate let kCellIdentifier = "ExampleCell"
    fileprivate let kJSWebURL = "https://dl.dropboxusercontent.com/u/64786881/JSSwiftBridge.html"
    
    // MARK: - Vars.
    fileprivate var messagesFromJS: Array<String> = Array<String>()
    fileprivate var bridge: SwiftJavascriptBridge = SwiftJavascriptBridge.bridge()
    @IBOutlet weak fileprivate var messagesTable: UITableView?
    
    // MARK: - Initialization.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:kNibName, bundle:Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Private methods.
    fileprivate func addSwiftHandlers() {
        // Add handlers that are going to be called from JavasCript with messages.
        weak var safeMe = self
        self.bridge.bridgeAddHandler("noDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive no data.
            safeMe?.printMessage("JS says: Calling noDataHandler.")
        });
        
        self.bridge.bridgeAddHandler("stringDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a string as data.
            let message = data as! String;
            safeMe?.printMessage(message)
        })
        
        self.bridge.bridgeAddHandler("integerDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a string as data.
            let number = data as! Int
            let message = String(format: "%@ %i.", "JS says: Calling integerDataHandler:", number)
            safeMe?.printMessage(message)
        })
        
        self.bridge.bridgeAddHandler("doubleDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a string as data.
            let number = data as! Double
            let message = String(format: "%@ %.9f", "JS says: Calling doubleDataHandler:", number)
            safeMe?.printMessage(message)
        })
        
        self.bridge.bridgeAddHandler("arrayDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive an array as data.
            let listMessages = data as! Array<String>;
            
            for message in listMessages {
                safeMe?.printMessage(message)
            }
        })
        
        self.bridge.bridgeAddHandler("dictionaryDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a dictionary as data.
            let dataDic = data as! Dictionary<String, String>
            safeMe?.printMessage(dataDic["message"])
        })
        
        self.bridge.bridgeAddHandler("callBackToJS", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a dictionary as data with a message. Prints the message and call
            // back a JS function with the same dictionary.
            
            // Prints the message.
            let dataDic = data as! Dictionary<String, String>
            safeMe?.printMessage(dataDic["message"])
            
            // Call JS Function with param.
            safeMe?.bridge.bridgeCallFunction("swiftCallBackJSFunction", data: dataDic as AnyObject?, callBackClosure: { (data: AnyObject?) -> Void in
                let dataDictionary = data as! Dictionary<String, String>
                let message: String = dataDictionary["message"]! + " (2)"
                safeMe?.printMessage(message)
            })
        })
    }
    
    fileprivate func callJSFunctions() {
        // Note: All JS functions then call handlerToPrintMessages handler to print a message.
        weak var safeMe = self
        
        // Call a JS Function without arguments.
        self.bridge.bridgeCallFunction("swiftCallWithNoData", data: nil, callBackClosure: { (data: AnyObject?) -> Void in
            let message = data as! String
            safeMe?.printMessage(message)
        })
        
        // Call a JS Function with a String as arguments.
        let message = String("Swift says: swiftCallWithStringData called.")
        self.bridge.bridgeCallFunction("swiftCallWithStringData", data: message as AnyObject?, callBackClosure: { (data: AnyObject?) -> Void in
            let message: String! = data as! String
            safeMe?.printMessage(message)
        })
        
        // Call a JS Function with an Int as arguments.
        self.bridge.bridgeCallFunction("swiftCallWithIntegerData", data: Int(4) as AnyObject?, callBackClosure: { (data: AnyObject?) -> Void in
            let integerData = data as! Int
            let message = String(format: "Swift says: swiftCallWithIntegerData called: %i.", integerData)
            safeMe?.printMessage(message)
            
        })
        
        // Call a JS Function with a Double as arguments.
        self.bridge.bridgeCallFunction("swiftCallWithDoubleData", data: Double(8.32743) as AnyObject?, callBackClosure: { (data: AnyObject?) -> Void in
            let doubleData = data as! Double
            let message = String(format: "Swift says: swiftCallWithDoubleData called: %.9f.", doubleData)
            safeMe?.printMessage(message)
        })
        
        // Call a JS Function with an Array as arguments.
        let messages: [String] = ["Swift says: swiftCallWithArrayData called.", "Swift says: swiftCallWithArrayData called. (2)"]
        self.bridge.bridgeCallFunction("swiftCallWithArrayData", data: messages as AnyObject?, callBackClosure: { (data: AnyObject?) -> Void in
            let messagesData = data as! [String]
            
            for message: String in messagesData {
                safeMe?.printMessage(message)
            }
        })
        
        // Call a JS Function with a Dictionary as arguments.
        let messageDict: [String : String] = ["message" : "Swift says: swiftCallWithDictionaryData called."]
        self.bridge.bridgeCallFunction("swiftCallWithDictionaryData", data: messageDict as AnyObject?, callBackClosure: { (data: AnyObject?) -> Void in
            let dataDictionary = data as! Dictionary<String, String>
            let message: String! = dataDictionary["message"]
            safeMe?.printMessage(message)
        })
    }
    
    // MARK: - View life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Swift Handlers to bridge. This handlers are going to be called from JS.
        self.addSwiftHandlers()
        
        self.bridge.bridgeLoadScriptFromURL(kJSWebURL)
        
        // Call JS functions.
        self.callJSFunctions()
    }
    
    
    // MARK: - Functions to be print message from JS.
    func printMessage(_ message: String!) {
        print(message)
    }


}
