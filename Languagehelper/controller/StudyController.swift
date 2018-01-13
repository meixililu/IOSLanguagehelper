//
//  StudyController.swift
//  Languagehelper
//
//  Created by luli on 16/04/2017.
//  Copyright © 2017 luli. All rights reserved.
//

import UIKit
import LeanCloud

class StudyController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("study-viewDidLoad")
        getDataTask();
        // Do any additional setup after loading the view.
    }
    
    func getDataTask(){
        let query = LCQuery(className: "Reading")
        query.whereKey("createdAt", .descending)
        query.limit = 10
        query.skip = 20
//        query.whereKey("priority", .equalTo(0))
//        query.whereKey("priority", .equalTo(1))
        
        // 如果这样写，第二个条件将覆盖第一个条件，查询只会返回 priority = 1 的结果
        query.find { result in
            switch result {
            case .success(let objects):
                print("查询成功")
                for object in objects{
                    let title: String = (object.get("title")?.stringValue)!
                    print( title )
                }
                break // 查询成功
            case .failure(let error):
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
