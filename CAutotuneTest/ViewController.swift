//
//  ViewController.swift
//  CAutotuneTest
//
//  Created by Rudyk Andrey on 21.02.22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    let engine = TestEngine()
    @IBAction func startDidPress(_ sender: UIButton) {
        engine.start()
    }
    
    @IBAction func stopDidPress(_ sender: UIButton) {
        engine.stop()
    }
}

