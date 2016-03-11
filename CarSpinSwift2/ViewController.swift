//
//  ViewController.swift
//  CarSpinSwift2
//
//  Created by Mo DeJong on 3/11/16.
//  Copyright © 2016 helpurock. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // Aspect fit view that will contain the rotating Car. This view must maintain
  // the aspect ratio so that the car will not stretch as it rotates around.
  
  @IBOutlet var carView: AVAnimatorView!
  
  // Media handle to decoded (loopable) file on disk
  
  var carMedia: AVAnimatorMedia!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    self.prepareCarMedia()
    
    // Setup animator ready callback, will be invoked after media is done loading
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "animatorPreparedNotification:",
      name: AVAnimatorPreparedToAnimateNotification,
      object: self.carMedia)
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "animatorStopNotification:",
      name: AVAnimatorDidStopNotification,
      object: self.carMedia)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // Note that NSNotificationCenter cleanup no longer needed at deinit time as of iOS 9
  
  func prepareCarMedia() {
    // Create resource loader that will combine RGB and Alpha values back
    // into one Maxvid file.
    
    let mixResourceName = "low_car_ANI_mix_30_main.m4v"
    
    // Output filename
    
    let tmpFilename = "Car.mvid"
    let tmpPath = AVFileUtil.getTmpDirPath(tmpFilename)
    
    // Set to TRUE to always decode from H.264
    
    let alwaysDecode = false
    
    if alwaysDecode && AVFileUtil.fileExists(tmpPath) {
      do {
        try NSFileManager.defaultManager().removeItemAtPath(tmpPath as String)
      } catch {
        assert(false, "could not remove file \"\(tmpPath)\"")
      }
    }
    
    // Loader that reads RGB and Alpha frames and combines to .mvid
    
    let resLoader = AVAssetMixAlphaResourceLoader.aVAssetMixAlphaResourceLoader()
    resLoader.movieFilename = mixResourceName;
    resLoader.outPath = tmpPath;
    
    //resLoader.alwaysGenerateAdler = TRUE;
    
    print("decoding mvid \"\(resLoader.outPath)\"");

    let media = AVAnimatorMedia.aVAnimatorMedia()
    media.resourceLoader = resLoader;
    
    self.carMedia = media;
    
    // Frame decoder will read from generated .mvid file
    
    let aVMvidFrameDecoder = AVMvidFrameDecoder.aVMvidFrameDecoder()
    media.frameDecoder = aVMvidFrameDecoder;
    
    // Media will direct video data into self.carLayer
    
    self.carView.attachMedia(media)
    
    if true {
      // Cycle background color change animation to demonstrate alpha channel
      
      self.carView.backgroundColor = UIColor.greenColor()
      UIView.beginAnimations(nil, context:nil)
      UIView.setAnimationDuration(5.0)
      UIView.setAnimationRepeatCount(30)
      UIView.setAnimationRepeatAutoreverses(true)
      self.carView.backgroundColor = UIColor.whiteColor()
      UIView.commitAnimations()
    }
    
    media.animatorRepeatCount = 1000;
    
    media.animatorFrameDuration = 1.0 / 30;
    
    media.prepareToAnimate();
    
    return;

  }

  // Invoked once a specific media object is ready to animate.
  
  func animatorPreparedNotification(notification: NSNotification)
  {
    let media = notification.object as! AVAnimatorMedia
    
    NSNotificationCenter.defaultCenter().removeObserver(self, name: AVAnimatorPreparedToAnimateNotification, object: media)

    let decoder = media.frameDecoder as! AVMvidFrameDecoder
    
    let file = (decoder.filePath as NSString).lastPathComponent
    
    print("prepared decoded mvid \"\(file)\"")
    
    self.carMedia.startAnimator()
  }
  
  // Invoked after the animator has finished playback. This logic switches the
  // backwards flag so that the next playback cycle will play from the end of
  // the video to the begining.

  func animatorStopNotification(notification: NSNotification)
  {
    self.carMedia.reverse = !self.carMedia.reverse
    
    self.carMedia.startAnimator()
    
    return;

  }

}

