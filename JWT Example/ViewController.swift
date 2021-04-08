//
//  ViewController.swift
//  JWT Example
//
//  Created by Vineet Rai on 08/04/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.startAnimating()
        JWTHelper.shared.refreshBearer {
            self.loadHealtData()
        }
    }
    
    func loadHealtData(){
        JWTHelper.shared.getHealthData {
            self.loader.stopAnimating()
        }
    }


}

