//
//  ViewController.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 13.10.2025.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var videoContainerView: UIView!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoContainerView.backgroundColor = .black
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }
    
    // MARK: HLS Test
    @IBAction func btnClick(_ sender: Any) {
        
        
        SecurityManager.shared.fetchSecureVideoUrl { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let secureUrl):
                    
                    print("*** success: \(secureUrl)")
                    
                    self.player?.pause()
                    self.playerLayer?.removeFromSuperlayer()
                    
                    let playerItem = AVPlayerItem(url: secureUrl)
                    self.player = AVPlayer(playerItem: playerItem)
                    self.playerLayer = AVPlayerLayer(player: self.player)
                    
                    self.playerLayer?.frame = self.videoContainerView.bounds
                    self.playerLayer?.videoGravity = .resizeAspect
                    
                    if let playerLayer = self.playerLayer {
                        self.videoContainerView.layer.addSublayer(playerLayer)
                    }
                    
                    self.player?.play()
                    
                    
                case .failure(let error):
                    print("*** error: \(error)")
                }
            }
        }
        
        
        
        
    }
    
}
