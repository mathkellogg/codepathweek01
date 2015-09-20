//
//  MovieViewController.swift
//
//
//  Created by Mathew Kellogg on 9/18/15.
//
//

import UIKit
import AFNetworking

func fixImageUrl(var url: String) -> String {
    let range = url.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
    if let range = range {
        url = url.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
    }
    return url.stringByReplacingOccurrencesOfString("_tmb.", withString: "_ori.")
}

class MovieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var movieTable: UITableView!
    var movies: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTable.dataSource = self
        movieTable.delegate = self
        
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
            
            //NSLog("response: \(self.movies)")
            self.movieTable.reloadData()

        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("com.mathewkellogg.MovieTableViewCell", forIndexPath: indexPath) as! MovieTableViewCell
        let movie = movies[indexPath.row] as! NSDictionary
        let posterUrlString = movie.valueForKeyPath("posters.original") as! String
        let posterUrl = NSURL(string: fixImageUrl(posterUrlString))
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
        // do something here
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
