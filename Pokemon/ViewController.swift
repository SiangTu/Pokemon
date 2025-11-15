//
//  ViewController.swift
//  Pokemon
//
//  Created by Sean on 2025/11/15.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        testAPI()
    }
    
    func testAPI() {
        _ = NetworkService.getPokemonList(limit: 9, offset: 0).done { result in
            print(result)
        }
    }


}

