//
//  ViewController.swift
//  VisionTest
//
//  Created by Roberto Osorio Goenaga on 11/26/18.
//  Copyright © 2018 Roberto Osorio Goenaga. All rights reserved.
//

import Cocoa
import Vision

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = NSImage(named: "6398615.jpg")
        var resultImage = image
        
        let detectFaceRequest = VNDetectFaceLandmarksRequest { (req, err) in
            if let results = req.results as? [VNFaceObservation] {
                for faceObservation in results {
                    guard let landmarks = faceObservation.landmarks else {
                        continue
                    }
                    let boundingBox = faceObservation.boundingBox
                    var landmarkRegions: [VNFaceLandmarkRegion2D] = []
                    if let faceContour = landmarks.faceContour {
                        landmarkRegions.append(faceContour)
                    }
                    resultImage = self.drawOnImage(source: resultImage!, boundingRect: boundingBox, faceLandmarkRegions: landmarkRegions)
                }
            }
        }
        let vnImage = VNImageRequestHandler(cgImage: image!.cgImage(forProposedRect: nil, context: NSGraphicsContext(cgContext: (NSGraphicsContext.current?.cgContext)!, flipped: false), hints: nil)!, options: [:])
        try? vnImage.perform([detectFaceRequest])
        // Do any additional setup after loading the view.
    }
    
    fileprivate func drawOnImage(source: NSImage,
                                 boundingRect: CGRect,
                                 faceLandmarkRegions: [VNFaceLandmarkRegion2D]) -> NSImage {
        let size = NSMakeSize(50, 50);
        let im = NSImage.init(size: size)
        
        let rep = NSBitmapImageRep.init(bitmapDataPlanes: nil,
                                        pixelsWide: Int(size.width),
                                        pixelsHigh: Int(size.height),
                                        bitsPerSample: 8,
                                        samplesPerPixel: 4,
                                        hasAlpha: true,
                                        isPlanar: false,
                                        colorSpaceName: NSColorSpaceName.calibratedRGB,
                                        bytesPerRow: 0,
                                        bitsPerPixel: 0)
        
        im.addRepresentation(rep!)
        im.lockFocus()
        
        let context = NSGraphicsContext.current?.cgContext
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.setBlendMode(CGBlendMode.colorBurn)
        context!.setLineJoin(.round)
        context!.setLineCap(.round)
        context!.setShouldAntialias(true)
        context!.setAllowsAntialiasing(true)
        
        let rectWidth = source.size.width * boundingRect.size.width
        let rectHeight = source.size.height * boundingRect.size.height
        
        //draw image
        let rect = CGRect(x: 0, y:0, width: source.size.width, height: source.size.height)
        context?.draw(source.cgImage(forProposedRect: nil, context: NSGraphicsContext(cgContext: context!, flipped: false), hints: nil)!, in: rect)
        
        
        //draw bound rect
        var fillColor = NSColor.green
        fillColor.setFill()
        context!.addRect(CGRect(x: boundingRect.origin.x * source.size.width, y:boundingRect.origin.y * source.size.height, width: rectWidth, height: rectHeight))
        context!.drawPath(using: CGPathDrawingMode.stroke)
        
        //draw overlay
        fillColor = NSColor.red
        fillColor.setStroke()
        context!.setLineWidth(2.0)
        for faceLandmarkRegion in faceLandmarkRegions {
            var points: [CGPoint] = []
            for i in 0..<faceLandmarkRegion.pointCount {
                let point = faceLandmarkRegion.normalizedPoints[i]
                let p = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
                points.append(p)
            }
            let mappedPoints = points.map { CGPoint(x: boundingRect.origin.x * source.size.width + $0.x * rectWidth, y: boundingRect.origin.y * source.size.height + $0.y * rectHeight) }
            context!.addLines(between: mappedPoints)
            context!.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        im.unlockFocus()
        
        let coloredImg : CGImage = context!.makeImage()!
        let returnImage = NSImage(cgImage: coloredImg, size: source.size)
        return returnImage
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

