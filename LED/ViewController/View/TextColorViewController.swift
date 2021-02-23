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


class TextColorViewController: BaseViewController, UIColorPickerViewControllerDelegate{
    
    var queueHTTP: DispatchQueue!
    var selectedRed: Int!
    var selectedGreen: Int!
    var selectedBlue: Int!
    var delegate:ModalViewControllerDelegate?
    @IBOutlet weak var textColorButton: UIButton!
    
    /** command event number  ***/
    final var GET_ALL_EVENT = 101
    final var SET_TEXT_COLOR_EVENT = 102
    
    override func viewDidLoad() {
        print("TextColorViewController-viewDidLoad")
        self.queueHTTP = DispatchQueue(label: "com.gomax.http", qos: DispatchQoS.userInitiated)
        self.textColorButton.layer.cornerRadius = 5
        self.textColorButton.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("TextColorViewController-viewWillAppear")
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
    
    override func viewWillDisappear(_ animated: Bool) {
        print("TextColorViewController-viewWillDisappear")
        delegate?.dismissed()
    }
    
}

extension TextColorViewController{
    
    //send text color
    @IBAction func sendTextColor(sender: UIButton) {
        DispatchQueue.main.async {
            let serverIP = self.getPreServerIP()
            if(serverIP.count > 0){
                self.queueHTTP.async {
                    let data = ["r":self.selectedRed, "g":self.selectedGreen, "b":self.selectedBlue]
                    self.sendHTTPPOST(ip: serverIP, cmd: HTTPHelper.CMD_TEXT_RGB, cmdNumber: self.SET_TEXT_COLOR_EVENT, data: data)
                }
            }else{
                DispatchQueue.main.async() {
                    self.view.makeToast("Please go to settings page and scan device first !", duration: 5.0, position: .bottom)
                }
            }
        }
    }
    
    //show text color picker
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
                    
                    let text_r =  CGFloat(json["text_rgb"]["r"].float!/255)
                    let text_g =  CGFloat(json["text_rgb"]["g"].float!/255)
                    let text_b =  CGFloat(json["text_rgb"]["b"].float!/255)
                    
                    print("text = \(text_r) \(text_g) \(text_b)")
                    
                    self.selectedRed = Int(text_r)
                    self.selectedGreen = Int(text_g)
                    self.selectedBlue = Int(text_b)
                    self.textColorButton.backgroundColor = UIColor(red: text_r, green: text_g, blue: text_b, alpha: 1)
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
                    
                case self.SET_TEXT_COLOR_EVENT:
                    print("SET_TEXT_COLOR_EVENT")
                    debugPrint(json)
                    if let result = json["result"].string{
                        
                        if(result == "ok"){
                            self.view.makeToast("Set text color successful !", duration: 3.0, position: .bottom)
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.showAlert(title: "Warning", message: "Set text color failed !")
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
        self.textColorButton.backgroundColor = UIColor(red: CGFloat(myColorComponents.red), green: CGFloat(myColorComponents.green), blue: CGFloat(myColorComponents.blue), alpha: 1)
    }
}
