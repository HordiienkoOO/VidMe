//
//  CustomNavigationBar.swift
//  VidMe
//
//  Created by cahebu4 on 05.05.17.
//  Copyright © 2017 cahebu4. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {
    

    override func draw(_ rect: CGRect) {
        let rect1 = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 2)
        super.draw(rect1)
    }

}
