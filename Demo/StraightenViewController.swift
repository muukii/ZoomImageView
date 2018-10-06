//
//  StraightenViewController.swift
//  Demo
//
//  Created by muukii on 10/5/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation

import ZoomImageView

class StraightenViewController: UIViewController {

  @IBOutlet weak var imageView: ZoomImageView!

  @IBOutlet weak var slider: UISlider!

  private var originalImageViewSize: CGSize!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.imageView.zoomMode = .fill
    self.imageView.image = #imageLiteral(resourceName: "5")

    originalImageViewSize = imageView.bounds.size
    print(originalImageViewSize)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

  }

  @IBAction func didChangeSliderValue(_ sender: Any) {

    let value = CGFloat(slider.value)

    let angle = value * (.pi / 4)

    let t = CGAffineTransform(rotationAngle: angle)

    let height = cos(abs(angle)) * originalImageViewSize.height + sin(abs(angle)) * originalImageViewSize.width
    let width = sin(abs(angle)) * originalImageViewSize.height + cos(abs(angle)) * originalImageViewSize.width

    imageView.bounds.size = CGSize(width: width, height: height)
    imageView.transform = t
  }
}
