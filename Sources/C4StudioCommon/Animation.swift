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

public class Animation {
    ///  Specifies the supported animation curves.
    public enum Curve {
        /// A linear animation curve causes an animation to occur evenly over its duration.
        case Linear
        /// An ease-out curve causes the animation to begin quickly, and then slow down as it completes.
        case EaseOut
        /// An ease-in curve causes the animation to begin slowly, and then speed up as it progresses.
        case EaseIn
        /// An ease-in ease-out curve causes the animation to begin slowly, accelerate through the middle of its duration, and then slow again before completing. This is the default curve for most animations.
        case EaseInOut
    }

    /// The amount of time to way before executing the animation.
    public var delay: NSTimeInterval = 0

    /// The duration of the animation, measured in seconds.
    public var duration: NSTimeInterval = 1

    /// The animation curve that the receiver will apply to the changes it is supposed to animate.
    public var curve: Curve = .EaseInOut

    /// A block with animations to execute.
    public var animations: () -> Void

    static var stack = [Animation]()
    static var currentAnimation: Animation? {
        return stack.last
    }

    public init(delay: NSTimeInterval, duration: NSTimeInterval, curve: Curve, animations: () -> Void) {
        self.delay = delay
        self.duration = duration
        self.curve = curve
        self.animations = animations
    }

    public var timingFunction: CAMediaTimingFunction {
        switch curve {
        case .Linear:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        case .EaseOut:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        case .EaseIn:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        case .EaseInOut:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        }
    }

    public var options: UIViewAnimationOptions {
        switch curve {
        case .Linear:
            return .CurveLinear
        case .EaseOut:
            return .CurveEaseOut
        case .EaseIn:
            return .CurveEaseIn
        case .EaseInOut:
            return .CurveEaseInOut
        }
    }

    /// Initiates the changes specified in the receivers `animations` block.
    public func animate() {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            UIView.animateWithDuration(self.duration, delay: 0, options: self.options, animations: {
                Animation.stack.append(self)
                self.doInTransaction(self.animations)
                Animation.stack.removeLast()
                }, completion:nil)
        }
    }

    private func doInTransaction(action: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(timingFunction)
        action()
        CATransaction.commit()
    }
}

extension CABasicAnimation {
    public func configureOptions() {
        self.fillMode = kCAFillModeBoth
        self.removedOnCompletion = false
    }
}
