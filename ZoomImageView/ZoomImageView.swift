// ZoomImageView.swift
//
// Copyright (c) 2016 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

open class ZoomImageView: UIScrollView, UIScrollViewDelegate {

  public enum ZoomMode {
    case fit
    case fill
  }

  // MARK: - Properties

  private let imageView = UIImageView()

  public var zoomMode: ZoomMode = .fit {
    didSet {
      updateImageView()
    }
  }

  open var image: UIImage? {
    get {
      return imageView.image
    }
    set {

      imageView.image = newValue
      oldSize = nil
      updateImageView()
    }
  }

  // MARK: - Initializers

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  // MARK: - Functions

  open func setup() {

    backgroundColor = UIColor.clear
    delegate = self
    imageView.contentMode = .scaleAspectFill
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    decelerationRate = UIScrollViewDecelerationRateFast
    addSubview(imageView)

    let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
    doubleTapGesture.numberOfTapsRequired = 2
    addGestureRecognizer(doubleTapGesture)
  }

  open override func didMoveToSuperview() {
    super.didMoveToSuperview()
  }

  open override func layoutSubviews() {

    super.layoutSubviews()

    if imageView.image != nil && oldSize != bounds.size {

      updateImageView()
      oldSize = bounds.size
    }

    if imageView.frame.width <= bounds.width {
      imageView.center.x = bounds.width * 0.5
    }

    if imageView.frame.height <= bounds.height {
      imageView.center.y = bounds.height * 0.5
    }
  }

  open override func updateConstraints() {
    super.updateConstraints()
    updateImageView()
  }

  private var oldSize: CGSize?

  private func updateImageView() {

    func fitSize(aspectRatio: CGSize, boundingSize: CGSize) -> CGSize {

      let widthRatio = (boundingSize.width / aspectRatio.width)
      let heightRatio = (boundingSize.height / aspectRatio.height)

      var boundingSize = boundingSize

      if widthRatio < heightRatio {
        boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height
      }
      else if (heightRatio < widthRatio) {
        boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width
      }
      return CGSize(width: ceil(boundingSize.width), height: ceil(boundingSize.height))
    }

    func fillSize(aspectRatio: CGSize, minimumSize: CGSize) -> CGSize {
      let widthRatio = (minimumSize.width / aspectRatio.width)
      let heightRatio = (minimumSize.height / aspectRatio.height)

      var minimumSize = minimumSize

      if widthRatio > heightRatio {
        minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height
      }
      else if (heightRatio > widthRatio) {
        minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width
      }
      return CGSize(width: ceil(minimumSize.width), height: ceil(minimumSize.height))
    }

    guard let image = imageView.image else { return }

    var size: CGSize

    switch zoomMode {
    case .fit:
      size = fitSize(aspectRatio: image.size, boundingSize: bounds.size)
    case .fill:
      size = fillSize(aspectRatio: image.size, minimumSize: bounds.size)
    }

    size.height = round(size.height)
    size.width = round(size.width)

    maximumZoomScale = image.size.width / size.width
    imageView.bounds.size = size
    contentSize = size
    imageView.center = contentCenter(forBoundingSize: bounds.size, contentSize: contentSize)
  }

  @objc private func handleDoubleTap() {
    if self.zoomScale == 1 {
      setZoomScale(max(1, maximumZoomScale / 3), animated: true)
    } else {
      setZoomScale(1, animated: true)
    }
  }

  // MARK: - UIScrollViewDelegate
  public func scrollViewDidZoom(_ scrollView: UIScrollView) {
    imageView.center = contentCenter(forBoundingSize: bounds.size, contentSize: contentSize)
  }

  public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {

  }

  public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {

  }

  public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  private func contentCenter(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGPoint {

    /// When the zoom scale changes i.e. the image is zoomed in or out, the hypothetical center
    /// of content view changes too. But the default Apple implementation is keeping the last center
    /// value which doesn't make much sense. If the image ratio is not matching the screen
    /// ratio, there will be some empty space horizontaly or verticaly. This needs to be calculated
    /// so that we can get the correct new center value. When these are added, edges of contentView
    /// are aligned in realtime and always aligned with corners of scrollview.
    let horizontalOffest = (boundingSize.width > contentSize.width) ? ((boundingSize.width - contentSize.width) * 0.5): 0.0
    let verticalOffset = (boundingSize.height > contentSize.height) ? ((boundingSize.height - contentSize.height) * 0.5): 0.0
    
    return CGPoint(x: contentSize.width * 0.5 + horizontalOffest,  y: contentSize.height * 0.5 + verticalOffset)
  }
}
