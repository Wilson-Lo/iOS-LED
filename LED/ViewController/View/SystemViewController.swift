//
//  SettingsViewController.swift
//  LED
//
//  Created by 啟發電子 on 2021/2/17.
//  Copyright © 2021 gomax. All rights reserved.
//

import UIKit
import Network
import RSSelectionMenu
import Toast_Swift
import SwiftSocket
import SwiftyJSON
import Alamofire

class SystemViewController: BaseViewController, UIColorPickerViewControllerDelegate{
    
    @IBOutlet weak var btSpeed: UIButton!
    @IBOutlet weak var btActionMode: UIButton!
    @IBOutlet weak var switchVivid: UISegmentedControl!
    @IBOutlet weak var btBackgroundColor: UIButton!
    @IBOutlet weak var btTextColor: UIButton!
    
    var menu: RSSelectionMenu<String>!
    var queueHTTP: DispatchQueue!
    var ledModeList: Array<String> = ["No Action", "Running", "Wave", "Running & Wave", "GIF"]
    var speedList: Array<String> = ["6", "5", "4", "3", "2", "1"]
    
    /** command event number  ***/
    final var GET_ALL_EVENT = 101
    final var SET_LED_MODE_EVENT = 102
    final var SET_SPEED_EVENT = 103
    final var SET_VIVID_EVENT = 104
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SystemViewController-viewDidLoad")
        self.btTextColor.layer.cornerRadius = 5
        self.btTextColor.layer.borderWidth = 1
        self.btBackgroundColor.layer.cornerRadius = 5
        self.btBackgroundColor.layer.borderWidth = 1
        self.switchVivid.addTarget(self, action: #selector(vividChanged(_:)), for: .valueChanged)
        self.queueHTTP = DispatchQueue(label: "com.gomax.http", qos: DispatchQoS.userInitiated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("SystemViewController-viewWillAppear")
        //check ip is stored in prefernceor not, if has ip do some things
        let serverIP = self.getPreServerIP()
        if(serverIP.count > 0){
            self.queueHTTP.async {
                self.sendHTTPGET(ip: serverIP, cmd: HTTPHelper.CMD_ALL, cmdNumber: self.GET_ALL_EVENT)
            }
        }else{
            DispatchQueue.main.async() {
                self.view.makeToast("Please go to settings page and scan device first !", duration: 5.0, position: .bottom)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare~~~~\(segue.identifier)")
        if segue.identifier == "TextColorViewController" {
            if let modalTextColorViewController = segue.destination as? TextColorViewController {
                modalTextColorViewController.delegate = self
            }
        }else if segue.identifier == "BackGroundColorViewController" {
            if let modalBackGroundColorViewController = segue.destination as? BackGroundColorViewController {
                modalBackGroundColorViewController.delegate = self
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("SystemViewController-viewWillDisappear")
    }
}

extension SystemViewController{
    
    //detect vivid change (SegmentedControl)
    @objc func vividChanged(_ sender: UISegmentedControl){
        print(sender.selectedSegmentIndex)
        var vividValue = 0
        if(sender.selectedSegmentIndex == 0){
            //on
            print("on")
            vividValue = 1
            
        }else if(sender.selectedSegmentIndex == 1){
            //off
            print("off")
            vividValue = 0
        }
        
        let serverIP = self.getPreServerIP()
        if(serverIP.count > 0){
            let data = ["vivid":vividValue]
            self.sendHTTPPOST(ip: serverIP, cmd: HTTPHelper.CMD_VIVID, cmdNumber: self.SET_VIVID_EVENT, data: data)
        }else{
            DispatchQueue.main.async() {
                self.view.makeToast("Please go to settings page and scan device first !", duration: 5.0, position: .bottom)
            }
        }
        
    }
    
    //show LED Mode list (LED Mode Button click event)
    @IBAction func showLEDMode(sender: UIButton) {
        DispatchQueue.main.async {
            self.closeLoading()
            var selectedNames: [String] = []
            // create menu with data source -> here [String]
            self.menu = RSSelectionMenu(dataSource: self.ledModeList) { (cell, name, indexPath) in
                cell.textLabel?.text = name
            }
            // provide selected items
            self.menu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                selectedNames = selectedItems
                
                switch(index){
                
                case 0:
                    //no action
                    self.btActionMode.setTitle("No Action", for: .normal)
                    break
                    
                case 1:
                    //running
                    self.btActionMode.setTitle("Running", for: .normal)
                    break
                    
                case 2:
                    //wave
                    self.btActionMode.setTitle("Wave", for: .normal)
                    break
                    
                case 3:
                    //running & wave
                    self.btActionMode.setTitle("Running & Wave", for: .normal)
                    break
                    
                case 4:
                    //gif
                    self.btActionMode.setTitle("GIF", for: .normal)
                    break
                    
                default:
                    
                    break
                }
                
                let serverIP = self.getPreServerIP()
                if(serverIP.count > 0){
                    let data = ["led_mode":index]
                    self.sendHTTPPOST(ip: serverIP, cmd: HTTPHelper.CMD_MODE, cmdNumber: self.SET_LED_MODE_EVENT, data: data)
                }else{
                    DispatchQueue.main.async() {
                        self.view.makeToast("Please go to settings page and scan device first !", duration: 5.0, position: .bottom)
                    }
                }
            }
            self.menu.show(from: self)
        }
    }
    
    @IBAction func showSpeed(sender: UIButton) {
        DispatchQueue.main.async {
            self.closeLoading()
            var selectedNames: [String] = []
            // create menu with data source -> here [String]
            self.menu = RSSelectionMenu(dataSource: self.speedList) { (cell, name, indexPath) in
                cell.textLabel?.text = name
            }
            // provide selected items
            self.menu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                selectedNames = selectedItems
                
                switch(index){
                
                case 0:
                    //fastest
                    self.btSpeed.setTitle("6", for: .normal)
                    break
                    
                case 1:
                    self.btSpeed.setTitle("5", for: .normal)
                    break
                    
                case 2:
                    self.btSpeed.setTitle("4", for: .normal)
                    break
                    
                case 3:
                    self.btSpeed.setTitle("3", for: .normal)
                    break
                    
                case 4:
                    self.btSpeed.setTitle("2", for: .normal)
                    break
                    
                case 5:
                    self.btSpeed.setTitle("1", for: .normal)
                    break
                    
                default:
                    
                    break
                }
                
                let serverIP = self.getPreServerIP()
                if(serverIP.count > 0){
                    let data = ["speed":index]
                    self.sendHTTPPOST(ip: serverIP, cmd: HTTPHelper.CMD_SPEED, cmdNumber: self.SET_SPEED_EVENT, data: data)
                }else{
                    DispatchQueue.main.async() {
                        self.view.makeToast("Please go to settings page and scan device first !", duration: 5.0, position: .bottom)
                    }
                }
            }
            self.menu.show(from: self)
        }
        
    }
    
    //send HTTP GET method
    public func sendHTTPGET(ip:String, cmd: String, cmdNumber: Int){
        AF.request("http://" + ip + ":" + self.SERVER_PORT + cmd, method: .get).response{ response in
            debugPrint(response)
            
            switch response.result{
            
            case .success(let value):
                let json = JSON(value)
                
                debugPrint(json)
                switch(cmdNumber){
                
                case self.GET_ALL_EVENT:
                    print("GET_ALL_EVENT")
                    if let led_mode = json["led_mode"].int{
                        print("mode = \(led_mode)")
                        
                        switch(led_mode){
                        
                        case 0:
                            //no action
                            self.btActionMode.setTitle("No Action", for: .normal)
                            break
                            
                        case 1:
                            //running
                            self.btActionMode.setTitle("Running", for: .normal)
                            break
                            
                        case 2:
                            //wave
                            self.btActionMode.setTitle("Wave", for: .normal)
                            break
                            
                        case 3:
                            //running & wave
                            self.btActionMode.setTitle("Running & Wave", for: .normal)
                            break
                            
                        case 4:
                            //gif
                            self.btActionMode.setTitle("GIF", for: .normal)
                            break
                            
                        default:
                            
                            
                            break
                        }
                    }
                    
                    if let speed = json["speed"].int{
                        print("speed = \(speed)")
                        switch(speed){
                        
                        case 0:
                            //fastest
                            self.btSpeed.setTitle("6", for: .normal)
                            break
                            
                        case 1:
                            self.btSpeed.setTitle("5", for: .normal)
                            break
                            
                        case 2:
                            self.btSpeed.setTitle("4", for: .normal)
                            break
                            
                        case 3:
                            self.btSpeed.setTitle("3", for: .normal)
                            break
                            
                        case 4:
                            self.btSpeed.setTitle("2", for: .normal)
                            break
                            
                        case 5:
                            self.btSpeed.setTitle("1", for: .normal)
                            break
                        default:
                            
                            
                            break
                        }
                    }
                    
                    if(json["vivid"].bool!){
                        self.switchVivid.selectedSegmentIndex = 0
                    }else{
                        self.switchVivid.selectedSegmentIndex = 1
                    }
                    
                    let background_r =  CGFloat(json["background_rgb"]["r"].float!/255)
                    let background_g =  CGFloat(json["background_rgb"]["g"].float!/255)
                    let background_b =  CGFloat(json["background_rgb"]["b"].float!/255)
                    
                    print("background = \(background_r) \(background_g) \(background_b)")
                    
                    self.btBackgroundColor.backgroundColor = UIColor(red: background_r, green: background_g, blue: background_b, alpha: 1)
                    
                    let text_r =  CGFloat(json["text_rgb"]["r"].float!/255)
                    let text_g =  CGFloat(json["text_rgb"]["g"].float!/255)
                    let text_b =  CGFloat(json["text_rgb"]["b"].float!/255)
                    
                    print("text = \(text_r) \(text_g) \(text_b)")
                    
                    self.btTextColor.backgroundColor = UIColor(red: text_r, green: text_g, blue: text_b, alpha: 1)
                    
                    
                    break
                    
                default:
                    
                    break
                }
                
                break
                
            case .failure(let error):
                debugPrint("HTTP GET request failed")
                DispatchQueue.main.async {
                    self.showAlert(title: "Warning", message: "Can't connect to LED !")
                }
                break
            }
        }
    }
    
    //send HTTP POST method
    public func sendHTTPPOST(ip:String, cmd: String, cmdNumber: Int, data: Parameters){
        debugPrint("sendHTTPPOST")
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        
        AF.request("http://" + ip + ":" + self.SERVER_PORT + cmd , method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).response{ response in
            //  debugPrint(response)
            
            switch response.result{
            
            case .success(let value):
                
                let json = JSON(value)
                debugPrint(json)
                
                switch(cmdNumber){
                
                case self.SET_LED_MODE_EVENT:
                    print("SET_LED_MODE")
                    if let result = json["result"].string{
                        
                        if(result == "ok"){
                            DispatchQueue.main.async() {
                                self.view.makeToast("Set LED mode successful !", duration: 3.0, position: .bottom)
                            }
                            
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.showAlert(title: "Warning", message: "Set LED mode failed !")
                            }
                        }
                        return
                    }
                    break
                    
                case self.SET_SPEED_EVENT:
                    print("SET_SPEED")
                    if let result = json["result"].string{
                        
                        if(result == "ok"){
                            DispatchQueue.main.async() {
                                self.view.makeToast("Set speed successful !", duration: 3.0, position: .bottom)
                            }
                            
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.showAlert(title: "Warning", message: "Set speed failed !")
                            }
                        }
                        return
                    }
                    break
                    
                case self.SET_VIVID_EVENT:
                    print("SET_VIVID")
                    if let result = json["result"].string{
                        
                        if(result == "ok"){
                            DispatchQueue.main.async() {
                                self.view.makeToast("Set colorful mode successful !", duration: 3.0, position: .bottom)
                            }
                            
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.showAlert(title: "Warning", message: "Set colorful mode failed !")
                            }
                        }
                        return
                    }
                    break
                    
                default:
                    
                    break
                }
                
                break
                
            case .failure(let error):
                debugPrint("HTTP POST request failed")
                DispatchQueue.main.async {
                    self.showAlert(title: "Warning", message: "Can't connect to LED !")
                }
                break
            }
        }
    }
    
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        print("finish \(color)")
        dismiss(animated: true, completion: nil)
        
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        print("SelectColor")
        let color = viewController.selectedColor
    }
}

extension SystemViewController: ModalViewControllerDelegate {
    func dismissed() {
        print("close~~~~")
        let serverIP = self.getPreServerIP()
        if(serverIP.count > 0){
            self.queueHTTP.async {
                self.sendHTTPGET(ip: serverIP, cmd: HTTPHelper.CMD_ALL, cmdNumber: self.GET_ALL_EVENT)
            }
        }
        // dismiss(animated: true, completion: nil)//dismiss the presented view controller
        //do whatever you want after it is dismissed
        //like opening another modal view controller
        //print("close~~~~")
    }
}
