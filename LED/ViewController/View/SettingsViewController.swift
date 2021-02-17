//
//  SettingsViewController.swift
//  LED
//
//  Created by 啟發電子 on 2021/2/17.
//  Copyright © 2021 gomax. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController {

    @IBOutlet weak var hostnameEditText: UITextField!
    @IBOutlet weak var hostnameApplyBt: UIButton!
    @IBOutlet weak var ipEditText: UITextField!
    @IBOutlet weak var appVerLabel: UILabel!
    @IBOutlet weak var scanBt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SettingsViewController-viewDidLoad")
        self.ipEditText.isUserInteractionEnabled = false
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        self.appVerLabel.text = "APP ver. " + String(version)
    }


    override func viewWillAppear(_ animated: Bool) {
        print("SettingsViewController-viewWillAppear")
    }
    
}

