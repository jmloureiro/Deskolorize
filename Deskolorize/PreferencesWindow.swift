//
//  PreferencesWindow.swift
//  Deskolorize
//
//  Created by João on 29/12/2016.
//  Copyright © 2016 ZOP. All rights reserved.
//

import Cocoa

struct Preferences {
    static let updatedNotification = "PreferencesUpdatedNotification"
}

class PreferencesWindow: NSWindowController {
    
    let notificationIdentifier: String = "PreferencesUpdatedNotification"
    
    @IBOutlet weak var featuredButton: NSButtonCell!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var searchTerm: NSTextFieldCell!
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        featuredButton.state = PreferencesWindow.featured() ? NSOnState : NSOffState
        searchButton.state = PreferencesWindow.search() ? NSOnState : NSOffState
        searchTerm.stringValue = PreferencesWindow.term()
    }
    
    @IBAction func featuredButtonClicked(_ sender: NSButtonCell) {
        let featured = featuredButton.state == NSOnState
        
        let defaults = UserDefaults.standard
        defaults.set(featured, forKey: "featured")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationIdentifier), object: nil)
    }
    
    @IBAction func searchButtonClicked(_ sender: NSButtonCell) {
        let search = searchButton.state == NSOnState
        
        let defaults = UserDefaults.standard
        defaults.set(search, forKey: "search")
        
        searchTerm.isEnabled = search
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationIdentifier), object: nil)
    }
    
    @IBAction func searchTermUpdated(_ sender: NSTextFieldCell) {
        var term = searchTerm.stringValue.trimmingCharacters(in: .whitespaces)
        
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9\\s]*$")
        let isValid = regex.firstMatch(in: term, options:[],
                                       range: NSMakeRange(0, term.characters.count)) != nil
        if isValid {
            let defaults = UserDefaults.standard
            defaults.set(term, forKey: "term")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationIdentifier), object: nil)
        } else {
            searchTerm.stringValue = PreferencesWindow.term()
            showAlert(message: "Error", text: "The search query can only contain letters, numbers and spaces.")
        }
    }
    
    func showAlert(message: String, text: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = message
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "Close")
        myPopup.runModal()
    }
    
    static func featured() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "featured")
    }
    
    static func search() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "search")
    }
    
    static func term() -> String {
        let defaults = UserDefaults.standard
        
        if let term = defaults.string(forKey: "term") {
            return term
        }
        
        return ""
    }
    
}
