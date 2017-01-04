//
//  MenuController.swift
//  Deskolorize
//
//  Created by João on 22/12/2016.
//  Copyright © 2016 ZOP. All rights reserved.
//

import Cocoa

class MenuController: NSObject {
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    var aboutWindow: AboutWindow!
    var preferencesWindow: PreferencesWindow!
    
    var unsplashAPI = UnsplashAPI()
    var photos = [Photo]()
    var currentPhotoIndex = 0
    
    override func awakeFromNib() {
        let icon = NSImage(named: "monitor")?.copy() as! NSImage
        icon.size = CGSize(width: 19, height: 17)
        icon.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        aboutWindow = AboutWindow()
        preferencesWindow = PreferencesWindow()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearCache),
                                               name: NSNotification.Name(rawValue: Preferences.updatedNotification),
                                               object: nil)
    }
    
    @IBAction func preferencesClicked(_ sender: Any) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func aboutClicked(_ sender: Any) {
        aboutWindow.showWindow(nil)
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        if (self.photos.count > 0) {
            let photo = self.photos.removeFirst()
            self.setPhotoAsWallpaper(photo: photo)
        } else {
            self.prepareTempDirectory()

            let featured = PreferencesWindow.featured()
            let search = PreferencesWindow.search()
            let term = search ? PreferencesWindow.term() : ""
            
            unsplashAPI.fetchPhotos(featured: featured, term: term, success: { (photos: [Photo]) in
                self.photos += photos
                let photo = self.photos.removeFirst()
                self.setPhotoAsWallpaper(photo: photo)
            })
        }
    }
    
    func setPhotoAsWallpaper(photo: Photo) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            do {
                let data = try Data(contentsOf: URL(string: photo.url)!)
                let workspace = NSWorkspace.shared()
                let screens = NSScreen.screens()
                let storagePath = self.storagePath()
                let imagePath = URL(fileURLWithPath: storagePath).appendingPathComponent("\(photo.id).jpg")
                
                try data.write(to: imagePath, options: Data.WritingOptions.atomic)
                
                for screen in screens! {
                    try workspace.setDesktopImageURL(imagePath, for: screen, options: [:])
                }
            }
            catch {
                print("Cannot set wallpaper.")
            }
        }
    }
    
    func prepareTempDirectory() {
        let storagePath = self.storagePath()

        if FileManager().fileExists(atPath: storagePath) {
            do {
                try FileManager().removeItem(atPath: storagePath)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        }
        
        do {
            try FileManager().createDirectory(atPath: storagePath, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func storagePath() -> String {
        let bundleId = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier")
        let applicationSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let storagePath = applicationSupportPath.appendingPathComponent(bundleId as! String)
        return storagePath.path
    }
    
    func clearCache() {
        photos.removeAll()
    }
    
}
