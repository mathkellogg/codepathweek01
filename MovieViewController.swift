//
//  MovieViewController.swift
//  
//
//  Created by Mathew Kellogg on 9/18/15.
//
//

import UIKit

class MovieViewController: UIViewController {
    
    var movies: NSArray = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, dataOrNil, errorOrNil) -> Void in
            if let data = dataOrNil {
                let object = try! NSJSONSerialization.JSONObjectWithData(data, options: [])
                self.movies = object["movies"] as! NSArray
            } else {
                if let error = errorOrNil {
                    NSLog("Error: \(error)")
                }
            }
            
            NSLog("response: \(self.movies)")
        }    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
