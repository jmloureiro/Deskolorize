//
//  AboutWindow.swift
//  Deskolorize
//
//  Created by João on 28/12/2016.
//  Copyright © 2016 ZOP. All rights reserved.
//

import Cocoa

class AboutWindow: NSWindowController {
    
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var versionLabel: NSTextFieldCell!
    
    override var windowNibName : String! {
        return "AboutWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        versionLabel.stringValue = "Version ".appending(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
        
        let attributedString = NSMutableAttributedString(attributedString: textView.attributedString())
        attributedString.addAttribute(NSLinkAttributeName, value: "https://unsplash.com/developers", range: NSRange(location: 26, length: 12))
        attributedString.addAttribute(NSLinkAttributeName, value: "http://www.freepik.com", range: NSRange(location: 53, length: 7))
        attributedString.addAttribute(NSLinkAttributeName, value: "http://www.flaticon.com", range: NSRange(location: 66, length: 16))
        
        textView.textStorage?.setAttributedString(attributedString)
    }
    
}
