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

import QuartzCore

public func CGPathCreateWithSVGString(string: String) -> CGPath? {
    let parser = SVGPathStringParser()
    return try? parser.parse(string)
}

class SVGPathStringParser {
    enum Error: ErrorType {
        case InvalidSyntax
        case MissingValues
    }

    let path = CGPathCreateMutable()
    var currentPoint = CGPoint()
    var lastControlPoint = CGPoint()

    var command: UnicodeScalar?
    var values = [CGFloat]()

    func parse(string: String) throws -> CGPath {
        let tokens = SVGPathStringTokenizer(string: string).tokenize()

        for token in tokens {
            switch token {
            case .Command(let c):
                command = c
                values.removeAll()

            case .Value(let v):
                values.append(v)
            }

            do {
                try addCommand()
            } catch Error.MissingValues {
                // Ignore
            }
        }

        return path
    }

    private func addCommand() throws {
        guard let command = command else {
            return
        }

        switch command {
        case "M":
            if values.count < 2 { throw Error.MissingValues }
            CGPathMoveToPoint(path, nil, values[0], values[1])
            currentPoint = CGPoint(x: values[0], y: values[1])
            lastControlPoint = currentPoint
            values.removeFirst(2)

        case "m":
            if values.count < 2 { throw Error.MissingValues }
            CGPathMoveToPoint(path, nil, currentPoint.x + values[0], currentPoint.y + values[1])
            currentPoint.x += values[0]
            currentPoint.y += values[1]
            lastControlPoint = currentPoint
            values.removeFirst(2)

        case "L":
            if values.count < 2 { throw Error.MissingValues }
            CGPathAddLineToPoint(path, nil, values[0], values[1])
            currentPoint = CGPoint(x: values[0], y: values[1])
            lastControlPoint = currentPoint
            values.removeFirst(2)

        case "l":
            if values.count < 2 { throw Error.MissingValues }
            CGPathAddLineToPoint(path, nil, currentPoint.x + values[0], currentPoint.y + values[1])
            currentPoint.x += values[0]
            currentPoint.y += values[1]
            lastControlPoint = currentPoint
            values.removeFirst(2)

        case "H":
            if values.count < 1 { throw Error.MissingValues }
            CGPathAddLineToPoint(path, nil, values[0], currentPoint.y)
            currentPoint.x = values[0]
            lastControlPoint = currentPoint
            values.removeFirst(1)

        case "h":
            if values.count < 1 { throw Error.MissingValues }
            CGPathAddLineToPoint(path, nil, currentPoint.x + values[0], currentPoint.y)
            currentPoint.x += values[0]
            lastControlPoint = currentPoint
            values.removeFirst(1)

        case "V":
            if values.count < 1 { throw Error.MissingValues }
            CGPathAddLineToPoint(path, nil, currentPoint.x, values[0])
            currentPoint.y = values[0]
            lastControlPoint = currentPoint
            values.removeFirst(1)

        case "v":
            if values.count < 1 { throw Error.MissingValues }
            CGPathAddLineToPoint(path, nil, currentPoint.x, currentPoint.y + values[0])
            currentPoint.y += values[0]
            lastControlPoint = currentPoint
            values.removeFirst(1)

        case "C":
            if values.count < 6 { throw Error.MissingValues }
            CGPathAddCurveToPoint(path, nil, values[0], values[1], values[2], values[3], values[4], values[5])
            lastControlPoint = CGPoint(x: values[2], y: values[3])
            currentPoint = CGPoint(x: values[4], y: values[5])
            values.removeFirst(6)

        case "c":
            if values.count < 6 { throw Error.MissingValues }
            CGPathAddCurveToPoint(path, nil, currentPoint.x + values[0], currentPoint.y + values[1], currentPoint.x + values[2], currentPoint.y + values[3], currentPoint.x + values[4], currentPoint.y + values[5])
            lastControlPoint = CGPoint(x: currentPoint.x + values[2], y: currentPoint.y + values[3])
            currentPoint.x += values[4]
            currentPoint.y += values[5]
            values.removeFirst(6)

        case "S":
            if values.count < 4 { throw Error.MissingValues }
            var controlPoint = CGPoint()
            controlPoint.x = currentPoint.x + (currentPoint.x - lastControlPoint.x)
            controlPoint.y = currentPoint.y + (currentPoint.y - lastControlPoint.y)
            CGPathAddCurveToPoint(path, nil, controlPoint.x, controlPoint.y, values[0], values[1], values[2], values[3])
            lastControlPoint = CGPoint(x: values[0], y: values[1])
            currentPoint = CGPoint(x: values[2], y: values[3])
            values.removeFirst(4)

        case "s":
            if values.count < 4 { throw Error.MissingValues }
            var controlPoint = CGPoint()
            controlPoint.x = currentPoint.x + (currentPoint.x - lastControlPoint.x)
            controlPoint.y = currentPoint.y + (currentPoint.y - lastControlPoint.y)
            CGPathAddCurveToPoint(path, nil, controlPoint.x, controlPoint.y, currentPoint.x + values[0], currentPoint.y + values[1], currentPoint.x + values[2], currentPoint.y + values[3])
            lastControlPoint = CGPoint(x: currentPoint.x + values[2], y: currentPoint.y + values[3])
            currentPoint.x += values[2]
            currentPoint.y += values[3]
            values.removeFirst(4)

        case "Q":
            if values.count < 4 { throw Error.MissingValues }
            CGPathAddCurveToPoint(path, nil, values[0], values[1], values[0], values[1], values[2], values[3])
            lastControlPoint = CGPoint(x: values[0], y: values[1])
            currentPoint = CGPoint(x: values[2], y: values[3])
            values.removeFirst(4)

        case "q":
            if values.count < 4 { throw Error.MissingValues }
            CGPathAddCurveToPoint(path, nil, currentPoint.x + values[0], currentPoint.y + values[1], currentPoint.x + values[0], currentPoint.y + values[1], currentPoint.x + values[2], currentPoint.y + values[3])
            lastControlPoint = CGPoint(x: currentPoint.x + values[0], y: currentPoint.y + values[1])
            currentPoint.x += values[2]
            currentPoint.y += values[3]
            values.removeFirst(4)

        case "T":
            if values.count < 2 { throw Error.MissingValues }
            var controlPoint = CGPoint()
            controlPoint.x = currentPoint.x + (currentPoint.x - lastControlPoint.x)
            controlPoint.y = currentPoint.y + (currentPoint.y - lastControlPoint.y)
            CGPathAddCurveToPoint(path, nil, controlPoint.x, controlPoint.y, controlPoint.x, controlPoint.y, values[0], values[1])
            lastControlPoint = controlPoint
            currentPoint = CGPoint(x: values[0], y: values[1])
            values.removeFirst(2)

        case "t":
            if values.count < 2 { throw Error.MissingValues }
            var controlPoint = CGPoint()
            controlPoint.x = currentPoint.x + (currentPoint.x - lastControlPoint.x)
            controlPoint.y = currentPoint.y + (currentPoint.y - lastControlPoint.y)
            CGPathAddCurveToPoint(path, nil, controlPoint.x, controlPoint.y, controlPoint.x, controlPoint.y, currentPoint.x + values[0], currentPoint.y + values[1])
            lastControlPoint = controlPoint
            currentPoint.x += values[0]
            currentPoint.y += values[1]
            values.removeFirst(2)

        case "Z", "z":
            CGPathCloseSubpath(path)
            self.command = nil

        default:
            throw Error.InvalidSyntax
        }
    }
}

class SVGPathStringTokenizer {
    enum Token {
        case Command(UnicodeScalar)
        case Value(CGFloat)
    }

    let separatorCharacterSet = NSCharacterSet(charactersInString: " \t\r\n,")
    let commandCharacterSet = NSCharacterSet(charactersInString: "mMLlHhVvzZCcSsQqTt")
    let numberStartCharacterSet = NSCharacterSet(charactersInString: "-+.0123456789")
    let numberCharacterSet = NSCharacterSet(charactersInString: ".0123456789")

    var string: String
    var range: Range<String.UnicodeScalarView.Index>

    init(string: String) {
        self.string = string
        range = string.unicodeScalars.startIndex..<string.unicodeScalars.endIndex
    }

    func tokenize() -> [Token] {
        var array = [Token]()
        while let token = nextToken() {
            array.append(token)
        }
        return array
    }

    func nextToken() -> Token? {
        skipSeparators()

        guard let c = get() else {
            return nil
        }

        if commandCharacterSet.isMember(c) {
            return .Command(c)
        }

        if numberStartCharacterSet.isMember(c) {
            var numberString = String(c)
            while let c = peek() where numberCharacterSet.isMember(c) {
                numberString += String(c)
                get()
            }

            // Handle exponent
            if peek() == "e" || peek() == "E" {
                get()
                guard let c = peek() where numberStartCharacterSet.isMember(c) else {
                    return nil
                }
                get()
                numberString += "e"
                numberString += String(c)

                while let c = peek() where numberCharacterSet.isMember(c) {
                    numberString += String(c)
                    get()
                }
            }

            if let value = Double(numberString) {
                return .Value(CGFloat(value))
            }
        }

        return nil
    }

    func get() -> UnicodeScalar? {
        guard range.startIndex != range.endIndex else {
            return nil
        }
        let c = string.unicodeScalars[range.startIndex]
        range.startIndex = range.startIndex.successor()
        return c
    }

    func peek() -> UnicodeScalar? {
        guard range.startIndex != range.endIndex else {
            return nil
        }
        return string.unicodeScalars[range.startIndex]
    }

    func skipSeparators() {
        while range.startIndex != range.endIndex && separatorCharacterSet.isMember(string.unicodeScalars[range.startIndex]) {
            range.startIndex = range.startIndex.successor()
        }
    }

}

extension NSCharacterSet {
    public func isMember(c: UnicodeScalar) -> Bool {
        return longCharacterIsMember(c.value)
    }
}
