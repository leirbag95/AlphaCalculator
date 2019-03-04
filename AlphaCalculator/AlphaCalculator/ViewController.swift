//
//  ViewController.swift
//  BigBigNumbers
//
//  Created by Khoa Pham on 26.05.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import UIKit
import Anchors
import AVFoundation
import Vision

class ViewController: UIViewController {

  private let cameraController = CameraController()
  private let visionService = VisionService()
  private let boxService = BoxService()
  private let ocrService = OCRService()
  private let musicService = MusicService()

  private lazy var label: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    label.textColor = .black
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraController.delegate = self
    add(childController: cameraController)
    activate(
      cameraController.view.anchor.edges
    )

    view.addSubview(label)
    activate(label.anchor.bottom.right.constant(-20))

    visionService.delegate = self
    boxService.delegate = self
    ocrService.delegate = self
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    musicService.play(fileName: "introduction")
  }
}

extension ViewController: CameraControllerDelegate {
  func cameraController(_ controller: CameraController, didCapture buffer: CMSampleBuffer) {
    visionService.handle(buffer: buffer)
  }
}

extension ViewController: VisionServiceDelegate {
  func visionService(_ version: VisionService, didDetect image: UIImage, results: [VNTextObservation]) {
    boxService.handle(
      cameraLayer: cameraController.cameraLayer,
      image: image,
      results: results,
      on: cameraController.view
    )
  }
}

extension ViewController: BoxServiceDelegate {
  func boxService(_ service: BoxService, didDetect images: [UIImage]) {
    guard let biggestImage = images.sorted(by: {
      $0.size.width > $1.size.width && $0.size.height > $1.size.height
    }).first else {
      return
    }

    ocrService.handle(image: biggestImage)
  }
}

extension ViewController: OCRServiceDelegate {
  func ocrService(_ service: OCRService, didDetect text: String) {
    label.text = text
    musicService.handle(text: text)
  }
}
