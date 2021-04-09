//
//  JWTHelper.swift
//  JWT Example
//
//  Created by Vineet Rai on 08/04/21.
//

import Foundation
import CryptoKit
import Alamofire

extension Data {
    func urlSafeBase64EncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

struct Header: Encodable {
    let alg = "HS256"
    let typ = "JWT"
}

struct Payload: Encodable {
    let clientId = "ebc38746-4bbe-4fd9-b695-3bd44ecb3afc"
    let individualId = "591cbcdf-4fec-4206-b651-2b7bf645979e"
    let canAssess = ["591cbcdf-4fec-4206-b651-2b7bf645979e"]
    let canMonitor = ["591cbcdf-4fec-4206-b651-2b7bf645979e"]
    let role = "consumer"
    let exp =  String(Int((NSDate().addingTimeInterval(TimeInterval(5.0 * 60.0))).timeIntervalSince1970))
}

class JWTHelper {
    
    typealias JWT = String
    var accessToken: JWT  = ""
    var bearer:JWT  = ""
    
    private init(){
        let secret = "58627c2e-d2f7-47ec-8ab6-b193a1f88658"
        let privateKey = SymmetricKey(data: secret.data(using: .utf8)!)

        let headerJSONData = try! JSONEncoder().encode(Header())
        let headerBase64String = headerJSONData.urlSafeBase64EncodedString()

        let payloadJSONData = try! JSONEncoder().encode(Payload())
        let payloadBase64String = payloadJSONData.urlSafeBase64EncodedString()

        let toSign = (headerBase64String + "." + payloadBase64String).data(using: .utf8)!

        let signature = HMAC<SHA256>.authenticationCode(for: toSign, using: privateKey)
        let signatureBase64String = Data(signature).urlSafeBase64EncodedString()

        let token = [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
        self.accessToken = token
    }
    
    static let shared = JWTHelper()

    func refreshBearer(completionHandler: @escaping () -> Void){
        let url: String = "https://security.alivesci.com/iam/sessions/ebc38746-4bbe-4fd9-b695-3bd44ecb3afc"
        let parameters: [String: Any] = ["access_token": self.accessToken]
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: ["Content-Type":"application/x-www-form-urlencoded"])
            .response { (response) -> Void in
                switch response.result {
                case .success:
                    let responseObj = try? JSONSerialization.jsonObject(with: response.data!, options: [])
                    if let response = responseObj as? [String: Any] {
                        self.bearer = response["access_token"] as! JWTHelper.JWT
                    }

                case .failure(let error):
                    print(error.localizedDescription)
                }
                completionHandler()
            }
    }
    
    func getHealthData(completionHandler: @escaping(_ weightedScores:Array<Any>) -> Void){
        let url: String = "https://healthscore.alivesci.com/analyzer/trends/individual/591cbcdf-4fec-4206-b651-2b7bf645979e"
        var request = URLRequest(url:  NSURL(string: url)! as URL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.bearer)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        AF.request(request).responseJSON { (response) -> Void in
            switch response.result {
            case .success:
                let responseObj = try? JSONSerialization.jsonObject(with: response.data!, options: [])
                if let response = responseObj as? [String: Any] {
                    let weightedScores = response["WeightedScores"] as! Array<Any>
                    completionHandler(weightedScores)
                }

            case .failure(let error):
                print(error.localizedDescription)
            }

        }
        
       
    }
    
}
