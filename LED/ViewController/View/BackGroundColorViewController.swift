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

class BackGroundColorViewController: BaseViewController{
    
    
    /** command event number  ***/
    final var GET_TEXT = 101
    final var SET_TEXT = 102
    
    override func viewDidLoad() {
        print("BackGroundColorViewController-viewDidLoad")
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("BackGroundColorViewController-viewWillAppear")
        
    }
    
}

extension BackGroundColorViewController{
    
    //send HTTP GET method
    public func sendHTTPGET(ip:String, cmd: String, cmdNumber: Int){
        AF.request("http://" + ip + ":" + self.SERVER_PORT + cmd, method: .get).response{ response in
            debugPrint(response)
            
            switch response.result{
                
            case .success(let value):
                let json = JSON(value)
                
                debugPrint(json)
                switch(cmdNumber){
                    
                case self.GET_TEXT:
                    print("GET_TEXT")
                    if let hostname = json["hostname"].string{
                       // self.textContentView.text = hostname
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

