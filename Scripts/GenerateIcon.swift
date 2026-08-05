#!/usr/bin/env swift

import AppKit
import CoreGraphics
import Foundation

let outputDir = "Resources/Assets.xcassets/AppIcon.appiconset"

let sizes: [(name: String, pixelSize: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

func drawIcon(size: Int) -> NSBitmapImageRep? {
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        return nil
    }
    rep.size = NSSize(width: size, height: size)

    guard let context = NSGraphicsContext(bitmapImageRep: rep) else {
        return nil
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    let ctx = context.cgContext
    let s = CGFloat(size)

    guard let bgGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.12, green: 0.11, blue: 0.13, alpha: 1.0),
            CGColor(red: 0.08, green: 0.07, blue: 0.09, alpha: 1.0)
        ] as CFArray,
        locations: [0.0, 1.0]
    ) else {
        NSGraphicsContext.restoreGraphicsState()
        return nil
    }
    ctx.drawLinearGradient(
        bgGradient,
        start: CGPoint(x: 0, y: s),
        end: CGPoint(x: 0, y: 0),
        options: []
    )

    let noiseSeed: UInt64 = 42
    var rngState = noiseSeed
    func nextRandom() -> CGFloat {
        rngState = rngState &* 6364136223846793005 &+ 1442695040888963407
        return CGFloat((rngState >> 33) & 0xFF) / 255.0
    }

    ctx.setBlendMode(.overlay)
    for _ in 0..<(size * size / 8) {
        let x = nextRandom() * s
        let y = nextRandom() * s
        let alpha = nextRandom() * 0.04
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: alpha))
        ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
    }
    ctx.setBlendMode(.normal)

    let centerX = s / 2
    let centerY = s * 0.58
    let radius = s * 0.32
    let tickOuterRadius = radius
    let tickInnerRadiusMajor = radius * 0.82
    let tickInnerRadiusMinor = radius * 0.88
    let arcLineWidth = s * 0.012

    let creamColor = CGColor(red: 0.92, green: 0.89, blue: 0.82, alpha: 1.0)
    let dimCreamColor = CGColor(red: 0.92, green: 0.89, blue: 0.82, alpha: 0.5)
    let amberColor = CGColor(red: 0.95, green: 0.65, blue: 0.20, alpha: 1.0)

    let startAngle = CGFloat.pi
    let endAngle = CGFloat.pi * 2

    ctx.setStrokeColor(dimCreamColor)
    ctx.setLineWidth(arcLineWidth)
    ctx.setLineCap(.round)
    ctx.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
    ctx.strokePath()

    let highlightStart = startAngle + (endAngle - startAngle) * 0.55
    let highlightEnd = startAngle + (endAngle - startAngle) * 0.80
    ctx.setStrokeColor(amberColor)
    ctx.setLineWidth(arcLineWidth * 1.8)
    ctx.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: highlightStart, endAngle: highlightEnd, clockwise: false)
    ctx.strokePath()

    let majorTickCount = 9
    let minorTicksPerMajor = 3

    for i in 0..<majorTickCount {
        let fraction = CGFloat(i) / CGFloat(majorTickCount - 1)
        let angle = startAngle + fraction * (endAngle - startAngle)

        let isHighlighted = fraction >= 0.55 && fraction <= 0.80
        let color = isHighlighted ? amberColor : creamColor

        let outerX = centerX + cos(angle) * tickOuterRadius
        let outerY = centerY + sin(angle) * tickOuterRadius
        let innerX = centerX + cos(angle) * tickInnerRadiusMajor
        let innerY = centerY + sin(angle) * tickInnerRadiusMajor

        ctx.setStrokeColor(color)
        ctx.setLineWidth(s * 0.015)
        ctx.setLineCap(.butt)
        ctx.move(to: CGPoint(x: innerX, y: innerY))
        ctx.addLine(to: CGPoint(x: outerX, y: outerY))
        ctx.strokePath()

        if i < majorTickCount - 1 {
            for j in 1...minorTicksPerMajor {
                let minorFraction = fraction + CGFloat(j) / (CGFloat(minorTicksPerMajor + 1) * CGFloat(majorTickCount - 1))
                let minorAngle = startAngle + minorFraction * (endAngle - startAngle)

                let mOuterX = centerX + cos(minorAngle) * tickOuterRadius
                let mOuterY = centerY + sin(minorAngle) * tickOuterRadius
                let mInnerX = centerX + cos(minorAngle) * tickInnerRadiusMinor
                let mInnerY = centerY + sin(minorAngle) * tickInnerRadiusMinor

                let mIsHighlighted = minorFraction >= 0.55 && minorFraction <= 0.80
                let mColor = mIsHighlighted ? amberColor : dimCreamColor

                ctx.setStrokeColor(mColor)
                ctx.setLineWidth(s * 0.008)
                ctx.move(to: CGPoint(x: mInnerX, y: mInnerY))
                ctx.addLine(to: CGPoint(x: mOuterX, y: mOuterY))
                ctx.strokePath()
            }
        }
    }

    let dotRadius = s * 0.018
    let dotX = centerX + cos((highlightStart + highlightEnd) / 2) * (radius * 0.7)
    let dotY = centerY + sin((highlightStart + highlightEnd) / 2) * (radius * 0.7)
    ctx.setFillColor(amberColor)
    ctx.fillEllipse(in: CGRect(x: dotX - dotRadius, y: dotY - dotRadius, width: dotRadius * 2, height: dotRadius * 2))

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

for item in sizes {
    guard let bitmap = drawIcon(size: item.pixelSize),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to generate \(item.name)")
        continue
    }
    let path = "\(outputDir)/\(item.name)"
    try pngData.write(to: URL(fileURLWithPath: path))
    print("Generated \(path) (\(bitmap.pixelsWide)x\(bitmap.pixelsHigh))")
}

print("Done.")
