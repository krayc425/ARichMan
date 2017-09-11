//
//  StartViewController.swift
//  ARichMan
//
//  Created by 宋 奎熹 on 2017/9/11.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var autoMoneyButton: UIButton!
    @IBOutlet weak var tapMoneyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        autoMoneyButton.layer.cornerRadius = 4.0
        autoMoneyButton.layer.masksToBounds = true
        tapMoneyButton.layer.cornerRadius = 4.0
        tapMoneyButton.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func moneyAction(_ sender: UIButton) {
        performSegue(withIdentifier: "moneySegue", sender: sender)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! ViewController
        let button = sender as! UIButton
        if button == autoMoneyButton {
            vc.isAuto = true
        } else if button == tapMoneyButton {
            vc.isAuto = false
        }
    }

}
