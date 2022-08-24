//
//  LaunchViewController.swift
//  ArKitDEMO
//
//  Created by Jay Buddhdev on 23/08/22.
//

import UIKit

class LaunchViewController: UIViewController {
    var navController: UINavigationController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickTargetShooting(_ sender: UIButton) {
        if let targetShootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "targetShootingViewController") as? TargetShootingViewController{
            self.navigationController?.pushViewController(targetShootVC, animated: true)
        }
    }
    @IBAction func onClickMeasureApp(_ sender: UIButton) {
        if let measureAppVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "measureAppViewController") as? MeasureAppViewController{
            self.navigationController?.pushViewController(measureAppVC, animated: true)
        }
    }
    
    @IBAction func onClickMissileLaunch(_ sender: UIButton) {
        if let missileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "missileViewController") as? MissileViewController{
            self.navigationController?.pushViewController(missileVC, animated: true)
        }
    }
}
   
