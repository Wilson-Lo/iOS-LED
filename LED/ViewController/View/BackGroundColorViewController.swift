//
//  BackGroundColorViewController.swift
//  LED
//
//  Created by GoMax on 2021/2/22.
//  Copyright © 2021 gomax. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BackGroundColorViewController: BaseViewController, UIColorPickerViewControllerDelegate{
    
    
    var queueHTTP: DispatchQueue!
    var selectedRed: Int!
    var selectedGreen: Int!
    var selectedBlue: Int!
    @IBOutlet weak var backgroundColorButton: UIButton!
    
    /** command event number  ***/
    final var GET_ALL_EVENT = 101
    final var SET_BACKGROUND_COLOR_EVENT = 102
    
    override func viewDidLoad() {
        print("BackGroundColorViewController-viewDidLoad")
        self.queueHTTP = DispatchQueue(label: "com.gomax.http", qos: DispatchQoS.userInitiated)
        self.backgroundColorButton.layer.cornerRadius = 5
        self.backgroundColorButton.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("BackGroundColorViewController-viewWillAppear")
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
    
}

extension BackGroundColorViewController{
    
    //send background color
    @IBAction func sendBackgroundColor(sender: UIButton) {
        DispatchQueue.main.async {
            let serverIP = self.getPreServerIP()
            if(serverIP.count > 0){
                self.queueHTTP.async {
                    let data = ["r":self.selectedRed, "g":self.selectedGreen, "b":self.selectedBlue]
                    self.sendHTTPPOST(ip: serverIP, cmd: HTTPHelper.CMD_BACKGROUND_RGB, cmdNumber: self.SET_BACKGROUND_COLOR_EVENT, data: data)
                }
            }else{
                DispatchQueue.main.async() {
                    self.view.makeToast("Please go to settings page and scan device first !", duration: 5.0, position: .bottom)
                }
            }
        }
    }
    
    //show background color picker
    @IBAction func showColorPicker(sender: UIButton) {
        DispatchQueue.main.async {
            let picker = UIColorPickerViewController()
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
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
                    let background_color_r =  CGFloat(json["background_rgb"]["r"].float!/255)
                    let background_color_g =  CGFloat(json["background_rgb"]["g"].float!/255)
                    let background_color_b =  CGFloat(json["background_rgb"]["b"].float!/255)
                    
                    print("background color = \(background_color_r) \(background_color_g) \(background_color_b)")
                    
                    self.selectedRed = Int(background_color_r)
                    self.selectedGreen = Int(background_color_g)
                    self.selectedBlue = Int(background_color_b)
                    self.backgroundColorButton.backgroundColor = UIColor(red: background_color_r, green: background_color_g, blue: background_color_b, alpha: 1)
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
                switch(cmdNumber){
                
                case self.SET_BACKGROUND_COLOR_EVENT:
                    print("SET_BACKGROUND_COLOR_EVENT")
                    debugPrint(json)
                    if let result = json["result"].string{
                        
                        if(result == "ok"){
                            self.view.makeToast("Set background color successful !", duration: 3.0, position: .bottom)
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.showAlert(title: "Warning", message: "Set background color failed !")
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
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        let myCIColor = color.coreImageColor
        let myColorComponents = color.components
        print("select color --- \(myColorComponents.red)  \(myColorComponents.green)  \(myColorComponents.blue)")
        self.selectedRed = Int((myColorComponents.red * 255))
        self.selectedGreen = Int((myColorComponents.green * 255))
        self.selectedBlue = Int((myColorComponents.blue * 255))
        self.backgroundColorButton.backgroundColor = UIColor(red: CGFloat(myColorComponents.red), green: CGFloat(myColorComponents.green), blue: CGFloat(myColorComponents.blue), alpha: 1)
    }
}

