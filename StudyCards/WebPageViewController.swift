//
//  WebPageViewController.swift
//  StudyCards
//
//  Created by Nanci Frank on 10/17/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class WebPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        qzWebView.loadRequest(URLRequest(url: URL(string: "https://quizlet.com/")!))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doneAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var qzWebView: UIWebView!

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
