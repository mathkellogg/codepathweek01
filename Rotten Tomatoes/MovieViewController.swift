//
//  MovieViewController.swift
//
//
//  Created by Mathew Kellogg on 9/18/15.
//
//

import UIKit
import AFNetworking
import JGProgressHUD


func isConnectedToNetwork() -> Bool {
    var status:Bool = false
    
    let url = NSURL(string: "https://google.com")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "HEAD"
    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
    request.timeoutInterval = 10.0
    
    var response:NSURLResponse?
    
    do{
        let _ = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) as NSData?
    }
    catch let error as NSError
    {
        print(error.localizedDescription)
    }
    
    if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode == 200 {
            status = true
        }
    }
    return status
}


func fixImageUrl(var url: String, thumb: Bool) -> String {
    if !thumb {
        url =  url.stringByReplacingOccurrencesOfString("_tmb.", withString: "_ori.")
        let range = url.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            url = url.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
    }
    return url
}

class MovieTabBar: UITabBar, UITabBarDelegate{
    
    var didSelectItemFunc:((String) -> (Void))?
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem){
        print("didselectitem")
        self.didSelectItemFunc!(item.title!)
    }
}

class MovieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var movieTable: UITableView!
    var movies: NSArray = []
    var refreshControl: UIRefreshControl!
    var dataset = "BoxOffice"
    @IBOutlet weak var tabBar: MovieTabBar!
    
    var dropdown: UIWindow?
    var dropdownLabel: UILabel?
    var dropdownWindow: UIWindow?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NSLog("view DID load")

        self.initializeDropdown()
        self.initializeRefreshControl()
        
        movieTable.dataSource = self
        movieTable.delegate = self
        
        let progressHUD = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        progressHUD.showInView(movieTable, animated: true)

        // initialize tab
        let tabBarHeight: CGFloat = 49.0
        self.tabBar.frame = CGRectMake(0.0, UIScreen.mainScreen().bounds.height - tabBarHeight, UIScreen.mainScreen().bounds.width, tabBarHeight)
        self.tabBar.didSelectItemFunc = { dset in
            print("didselectitemfunc")
            self.dataset = dset
            progressHUD.showInView(self.movieTable, animated: true)
            self.fetch_data(){
                self.movieTable.reloadData()
                //self.movieTable.setContentOffset(CGPointZero, animated:false)
                progressHUD.dismiss()
            }
        }
        
        self.tabBar.delegate = self.tabBar
        
        self.fetch_data(){
            self.movieTable.reloadData()
            progressHUD.dismiss()
        }
        
        
    }
    
    func initializeDropdown(){
        self.dropdown = UIWindow(frame: CGRectMake(0, -20, UIScreen.mainScreen().bounds.width, 20))
        self.dropdown!.backgroundColor = UIColor.redColor()
        self.dropdownLabel = UILabel(frame: self.dropdown!.bounds)
        self.dropdownLabel!.textAlignment = NSTextAlignment.Center
        self.dropdownLabel!.font = UIFont.systemFontOfSize(12)
        self.dropdownLabel!.backgroundColor = UIColor.clearColor()
        self.dropdown!.addSubview(self.dropdownLabel!)
        self.dropdown!.windowLevel = UIWindowLevelStatusBar
        self.dropdown!.makeKeyAndVisible()
        self.dropdown!.resignKeyWindow()

    }

    func initializeRefreshControl(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.movieTable.addSubview(refreshControl)
    }
    
    func animateDropdown(text:String){
        self.dropdownLabel!.text = text
        let screenWidth = UIScreen.mainScreen().bounds.width
        UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations:{
                self.dropdown!.frame = CGRectMake(0, 0, screenWidth, 20)
            }, completion: {
                finished in
                UIView.animateWithDuration(0.5, delay: 2.0, options: [], animations: {
                    self.dropdown!.frame = CGRectMake(0, -20, screenWidth, 20)
                }, completion: {
                    finished in
                    //done yay!
                })
            }
        )
        
    }
    
    func refresh(sender:AnyObject){
        self.fetch_data(){
            self.refreshControl!.endRefreshing()
        }
    }
    
    func fetch_data(callback: () -> Void){
        
        if !isConnectedToNetwork() {
            
            animateDropdown("Unable to Connect to Network.")

            //return
        } else {
            //animateDropdown("Connected to Network!")
        }
        
        var url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!

        // Code to refresh table view
        switch self.dataset {
            case "Box Office":
                url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
            case "DVDs":
                url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json")!
            default:
                url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!

        }
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
            
            //NSLog("response: \(self.movies)")
            callback()
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("com.mathewkellogg.MovieTableViewCell", forIndexPath: indexPath) as! MovieTableViewCell
        let movie = self.movies[indexPath.row] as! NSDictionary
        let posterUrlString = movie.valueForKeyPath("posters.original") as! String
        let posterUrl = NSURL(string: fixImageUrl(posterUrlString, thumb: true))
        cell.TitleLabel.text = movie["title"] as? String
        cell.DescriptionLabel.text = movie["synopsis"] as? String
        cell.MovieImage.setImageWithURL(posterUrl!)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //delegate and datasource functions
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        
        if segue.identifier == "moviedetail" {
            
        let vc = segue.destinationViewController as! MovieDetailViewController
        
        let indexPath = movieTable.indexPathForCell(sender as! UITableViewCell)
        let movie = movies[indexPath!.row] as! NSDictionary
        vc.movie = movie

        }
    }
    
}
