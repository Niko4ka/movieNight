//
//  VideoPlayerViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 19/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import WebKit

class VideoPlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!

    var videoID = "oB6vrhI5SCw"
    var didLoadVideo = false

    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.configuration.mediaTypesRequiringUserActionForPlayback = []
        activityIndicator.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !didLoadVideo {
            playerView.loadHTMLString(embedVideoHtml, baseURL: URL(string: "http://www.youtube.com"))
            didLoadVideo = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeVisible(notification:)), name: UIWindow.didBecomeVisibleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeHidden(notification:)), name: UIWindow.didBecomeHiddenNotification, object: nil)
    }
    
    @objc func windowDidBecomeVisible(notification: NSNotification) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        closeButton.isHidden = true
    }
    
    @objc func windowDidBecomeHidden(notification: NSNotification) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private var embedVideoHtml: String {
        return """
        <!DOCTYPE html>
        <html>
        <body>
        <!-- 1. The <iframe> (and video player) will replace this <div> tag. -->
        <div id="player"></div>
        
        <script>
        var tag = document.createElement('script');
        
        tag.src = "https://youtube.com/iframe_api";
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
        
        var player;
        function onYouTubeIframeAPIReady() {
        player = new YT.Player('player', {
        height: '\(playerView.frame.height)',
        width: '\(playerView.frame.width)',
        videoId: '\(videoID)',
        events: {
        'onReady': onPlayerReady
        }
        });
        }
        
        function onPlayerReady(event) {
        event.target.playVideo();
        }
        </script>
        </body>
        </html>
        """
    }
    
    
    
 
    

}
