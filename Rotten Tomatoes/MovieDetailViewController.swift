//
//  MovieDetailViewController.swift
//  Rotten Tomatoes
//
//  Created by Mathew Kellogg on 9/19/15.
//  Copyright © 2015 Mathew Kellogg. All rights reserved.
//

import UIKit


class MovieDetailViewController: UIViewController {

    var movie: NSDictionary!
    @IBOutlet weak var BackgroundImage: UIImageView!
    @IBOutlet weak var ForegroundImage: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set text labels
        self.TitleLabel.text = movie["title"] as? String
        self.DescriptionLabel.text = movie["synopsis"] as? String
        self.DescriptionLabel.sizeToFit()
        
        //draw blurry ForegroundImage
        let posterUrlString = movie.valueForKeyPath("posters.original") as! String
        let posterUrl = NSURL(string: fixImageUrl(posterUrlString, thumb: false))
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = ForegroundImage.bounds
        ForegroundImage.addSubview(blurView)
        self.ForegroundImage.setImageWithURL(posterUrl!)

        //draw blurry BackgroundImage
        self.BackgroundImage.setImageWithURL(posterUrl!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
