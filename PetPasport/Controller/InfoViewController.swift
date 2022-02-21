//
//  InfoViewController.swift
//  PetPasport
//
//  Created by Сергей on 21.11.2020.
//  Copyright © 2020 Сергей. All rights reserved.
//

import UIKit
import WebKit


class InfoViewController: UIViewController {
    
    
    @IBOutlet weak var infoWebView: WKWebView!
    var filePath: [String] = ["", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            guard let filePath = Bundle.main.path(forResource: filePath[0], ofType: filePath[1], inDirectory: filePath[2])
                else {
                    print ("File reading error")
                    return
            }
            print ("File was found")
            
            let baseUrl = URL(fileURLWithPath: filePath)
            let contents =  try String(contentsOf: baseUrl, encoding: .utf8)
            infoWebView.loadHTMLString((contents as String), baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
    }
}

