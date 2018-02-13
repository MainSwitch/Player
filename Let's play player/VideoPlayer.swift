//
//  VideoPlayer.swift
//  Let's play player
//
//  Created by Anton on 17.01.2018.
//  Copyright © 2018 Anton. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayer: UIViewController {

    @IBOutlet weak var VideoViev: UIView!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var Time: CMTime!
    var isVideoPlay = false
    
    @IBOutlet weak var currentTimeLBL: UILabel!
    @IBOutlet weak var durationTimeLBL: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        let vURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        player = AVPlayer(url: vURL)
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new,.initial], context: nil)
        addTimeObserver()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        VideoViev.layer.addSublayer(playerLayer)
        let currentTime = CMTimeGetSeconds(player.currentTime())
        Time = CMTimeMake(Int64(currentTime*1000),1000)
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = VideoViev.bounds
    }
    
    func addTimeObserver(){
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQeue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQeue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLBL.text = self?.getTimeString(from: currentItem.currentTime())
        })
    }
    @IBAction func Play(_ sender: UIButton) {
        if isVideoPlay{
            player.pause()
            sender.setTitle("|>", for: .normal)
        }else{
            player.play()
            sender.setTitle("||", for: .normal)
        }
        isVideoPlay = !isVideoPlay
    }
    
    @IBAction func Forward(_ sender: Any) {
        guard let duration = player.currentItem?.duration else {return}
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 5.0
        if newTime < CMTimeGetSeconds(duration) - 5.0{
            let time:CMTime = CMTimeMake(Int64(newTime*1000), 1000)
            player.seek(to: time)
            
       }
    }
    
    @IBAction func Backwards(_ sender: Any) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 5.0
        if newTime < 0 {
            newTime = 0
        }
        let time:CMTime = CMTimeMake(Int64(newTime*1000), 1000)
        player.seek(to: time)
    }
    
    @IBAction func Ready(_ sender: Any) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        Time = CMTimeMake(Int64(currentTime*1000),1000)
        player.pause()
    }
  
    @IBAction func sliderTimeCH(_ sender: UISlider) {
        player.seek(to: CMTimeMake(Int64(sender.value*1000), 1000))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.durationTimeLBL.text = getTimeString(from: player.currentItem!.duration)
        }
    }
    
    func getTimeString(from time:CMTime) -> String{
        let totalSecond = CMTimeGetSeconds(time)
        let hours = Int(totalSecond/3600)
        let minutes = Int(totalSecond/60) % 60
        let seconds = Int(totalSecond.truncatingRemainder(dividingBy: 60))
        if hours > 0{
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else{
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
}
