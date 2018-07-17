//
//  MapViewController.swift
//  ParentChildren
//
//  Created by nmi on 2018/7/17.
//  Copyright © 2018 nmi. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("MapViewController")
        self.view.layer.borderWidth = 2
        self.view.layer.borderColor = UIColor.gray.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
       print("deinit")
    }
    

}
