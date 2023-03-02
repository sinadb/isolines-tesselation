//
//  AppDelegate.swift
//  Tesselation
//
//  Created by Sina Dashtebozorgy on 27/02/2023.
//

import Cocoa


var Scene : Mode?
var vCPs : extraCP?


@main

class AppDelegate: NSObject, NSApplicationDelegate {

  
    @IBOutlet weak var linear0: NSMenuItem!
    @IBOutlet weak var linear1: NSMenuItem!
    @IBOutlet weak var linear2: NSMenuItem!
    
    @IBOutlet weak var second0: NSMenuItem!
    @IBOutlet weak var second1: NSMenuItem!
    @IBOutlet weak var second2: NSMenuItem!
    
    @IBOutlet weak var third0: NSMenuItem!
    @IBOutlet weak var third1: NSMenuItem!
    @IBOutlet weak var third2: NSMenuItem!
    
    
    
    @IBAction func setScene(_ sender: NSMenuItem) {
        
        switch sender {
        case linear0:
            Scene = .linear
            vCPs = .v_0
            break
        case linear1:
            Scene = .linear
            vCPs = .v_1
            break
        case linear2:
            Scene = .linear
            vCPs = .v_2
            break
        case second0:
            Scene = .second
            vCPs = .v_0
            break
        case second1:
            Scene = .second
            vCPs = .v_1
            break
        case second2:
            Scene = .second
            vCPs = .v_2
            break
        case third0:
            Scene = .third
            vCPs = .v_0
            break
        case third1:
            Scene = .third
            vCPs = .v_1
            break
        case third2:
            Scene = .third
            vCPs = .v_2
            break
        default:
            break
        }
    }
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

