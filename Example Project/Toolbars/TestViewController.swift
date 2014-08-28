//
//  TestViewController.swift
//  Toolbars
//
//  Created by Pete Morris on 27/08/2014.
//  Copyright (c) 2014 Mumsnet. All rights reserved.
//

import UIKit

class TestViewController: CollapsingNavigationViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var tableCell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "test")
        tableCell.textLabel.text = "test 2"
        return tableCell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
