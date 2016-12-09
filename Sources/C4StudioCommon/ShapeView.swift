// Copyright © 2016 JABT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import UIKit

public class ShapeView: UIView {
    public var shapeLayer: ShapeLayer {
        return layer as! ShapeLayer
    }

    public var path: CGPath? {
        get {
            return shapeLayer.path
        }
        set {
            shapeLayer.path = newValue
        }
    }

    override public class func layerClass() -> AnyClass {
        return ShapeLayer.self
    }
}

/// Extension for CAShapeLayer that makes animation code simpler
public class ShapeLayer: CAShapeLayer {
    public override func actionForKey(key: String) -> CAAction? {
        if key == "lineWidth" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = lineWidth
            return animation;
        } else if key == "strokeEnd" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = strokeEnd
            return animation;
        } else if key == "strokeStart" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = strokeStart
            return animation;
        } else if key == "strokeColor" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = strokeColor
            return animation;
        } else if key == "path" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = path
            return animation;
        } else if key == "fillColor" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = fillColor
            return animation;
        } else if key == "lineDashPhase" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = lineDashPhase
            return animation;
        } else if key == "shadowColor" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = shadowColor
            return animation;
        } else if key == "shadowOffset" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = NSValue(CGSize: shadowOffset)
            return animation;
        } else if key == "shadowOpacity" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = shadowOpacity
            return animation;
        } else if key == "shadowRadius" {
            let animation = CABasicAnimation(keyPath: key)
            animation.configureOptions()
            animation.fromValue = shadowRadius
            return animation;
        }

        return super.actionForKey(key)
    }
}

