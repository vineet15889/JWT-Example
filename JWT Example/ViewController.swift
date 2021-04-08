//
//  ViewController.swift
//  JWT Example
//
//  Created by Vineet Rai on 08/04/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(JWTHelper.shared.accessToken)
    }


}

