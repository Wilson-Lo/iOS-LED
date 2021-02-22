//
//  TextViewController.swift
//  LED
//
//  Created by 啟發電子 on 2021/2/19.
//  Copyright © 2021 gomax. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TextViewController: BaseViewController{
    
    var queueHTTP: DispatchQueue!
    @IBOutlet weak var textContentView: UITextView!
    
    /** command event number  ***/
    final var GET_TEXT_EVENT = 101
    final var SET_TEXT_EVENT = 102
    
    override func viewDidLoad() {
        print("TextViewController-viewDidLoad")
        super.viewDidLoad()
        self.textContentView.layer.cornerRadius = 5
        self.textContentView.layer.borderWidth = 1
        self.queueHTTP = DispatchQueue(label: "com.gomax.http", qos: DispatchQoS.userInitiated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("TextViewController-viewWillAppear")
        let serverIP = self.getPreServerIP()
        if(serverIP.count > 0){
            self.queueHTTP.async {
                self.sendHTTPGET(ip: serverIP, cmd: HTTPHelper.CMD_TEXT, cmdNumber: self.GET_TEXT_EVENT)
            }
        }else{
            DispatchQueue.main.async() {
                self.view.makeToast("Please go to settings page and scan device first !", duration: 5.0, position: .bottom)
            }
        }
        
        
    }
    
    
}

extension TextViewController{
    
    //set text content
    @IBAction func setTextContent(sender: UIButton) {
        DispatchQueue.main.async {
            
            let serverIP = self.getPreServerIP()
            if(serverIP.count > 0){
                let data = ["content": self.textContentView.text]
                self.sendHTTPPOST(ip: serverIP, cmd: HTTPHelper.CMD_TEXT, cmdNumber: self.SET_TEXT_EVENT, data: data)
            }else{
                DispatchQueue.main.async() {
                    self.view.makeToast("Please go to settings page and scan device first !", duration: 5.0, position: .bottom)
                }
            }
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
                
                case self.GET_TEXT_EVENT:
                    print("GET_TEXT")
                    if let text_content = json["content"].string{
                        self.textContentView.text = text_content
                    }
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
                
                case self.SET_TEXT_EVENT:
                    print("SET_TEXT")
                    debugPrint(json)
                    
                    if let result = json["result"].string{
                        
                        if(result == "ok"){
                            DispatchQueue.main.async{
                                self.view.makeToast("Set text content successful !", duration: 3.0, position: .bottom)
                            }
                            
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.showAlert(title: "Warning", message: "Set content failed !")
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
    
}
