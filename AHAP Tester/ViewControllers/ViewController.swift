//
//  ViewController.swift
//  AHAP Tester
//
//  Created by Andrea Mazzini on 26/06/2019.
//  Copyright © 2019 Fancy Pixel. All rights reserved.
//

import UIKit
import CoreHaptics
import AVFoundation
import Combine

class ViewController: UIViewController {
  @IBOutlet private var loadButton: UIButton!
  @IBOutlet private var playButton: UIButton!
  @IBOutlet private var textField: UITextField!
  @IBOutlet private var stateLabel: UILabel!
  @IBOutlet private var activityIndicator: UIActivityIndicatorView!
  
  private var engine: CHHapticEngine?
  private var isEngineRunning: Bool = false
  private var hapticData: Data? {
    didSet {
      playButton.alpha = hapticData != nil ? 1 : 0.8
      playButton.isEnabled = hapticData != nil
      stateLabel.text = hapticData != nil ? "HAPTIC READY" : "NO HAPTIC LOADED"
    }
  }
  private var fetching = false {
    didSet {
      if fetching {
        loadButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
      } else {
        loadButton.setTitle("LOAD AHAP", for: .normal)
        activityIndicator.stopAnimating()
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    engine = try? CHHapticEngine()
    engine?.stoppedHandler = { [weak self] reason in
      print("Stopped for reason: \(reason.rawValue)")
      self?.isEngineRunning = false
    }
    do {
      try engine?.start()
      isEngineRunning = true
    } catch let error {
      fatalError("Unable to start: \(error)")
    }
    
    hapticData = nil
  }
  
  @IBAction func loadDemo() {
    hapticData = try! Data(contentsOf: Bundle.main.url(forResource: "demo", withExtension: "json")!)
  }

  @IBAction func playHaptic() {
    guard let hapticData = hapticData else { return }
    
    try? engine?.playPattern(from: hapticData)
  }
  
  @IBAction func loadHaptic() {
    guard let url = URL(string: textField.text ?? ""), !fetching else { return }
    
    textField.resignFirstResponder()
    fetching = true
    DispatchQueue(label: "load").async {
      do {
        let data = try Data(contentsOf: url)
        DispatchQueue.main.async {
          self.hapticData = data
          self.fetching = false
        }
      } catch let error {
        print("Unable to load file: \(error)")
      }
    }
  }
  
  @IBAction func scanQR() {
    let controller = ScanViewController.instantiate(fromAppStoryboard: .Main)
    controller.delegate = self
    present(controller, animated: true, completion: nil)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    textField.resignFirstResponder()
  }
}

extension ViewController: ScanViewControllerDelegate {
  func scanViewController(_ controller: ScanViewController, didScan code: String) {
    textField.text = code
  }
}
