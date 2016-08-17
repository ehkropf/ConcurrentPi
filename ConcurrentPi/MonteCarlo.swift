import Foundation

/// Define power operator.
infix operator ** {associativity left precedence 160}
public func **(radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

public struct MonteGlobals {
    public static var trials: Int = 2**16
    public static var jobs: Int = 4
}

extension Double {
    /// Need a uniform random double between 0 and 1 (inclusive).
    public static var random: Double {
        return Double(arc4random())/0xffffffff
    }
}


/// Point in the plane.
public struct Point {
    public var x: Double
    public var y: Double
}

extension Point {
    /// Uniform random point in the unit rectangle.
    public static var randomInUnitRect: Point {
        return Point(x: Double.random, y: Double.random)
    }
    
    /// Is the point in the unit circle?
    public var isInCircle: Bool {
        return (x*x + y*y) <= 1.0
    }
}

extension Double {
    /// Serially calculate area ratio.
    public static var piEstimateSerial: Double {
        let trials = MonteGlobals.trials
        var inCircle = 0
        for _ in 0..<trials {
            inCircle += Int(Point.randomInUnitRect.isInCircle)
        }
        return Double(4*inCircle)/Double(trials)
    }
    
    /**
     Trying concurrent operation queues.
     Using numberOfOperations, we integer divide trials to get the number of trials per operation. (Left over trials done at the end, since there will be at most numberOfOperations.)
     */
    public static var piEstimateQueue: Double {
        let queue = NSOperationQueue()
        let numberOfOps = 64
        let trials = MonteGlobals.trials
        let trialsPerOp = trials/numberOfOps
        let leftOver = trials%numberOfOps
        print("\(trials) split into \(numberOfOps) operations for \(trialsPerOp) trials each. \(leftOver) left over.")
        
        var jobResult = [Int].init(count: numberOfOps, repeatedValue: 0)
        let blockOps = NSBlockOperation()
        for i in 0..<numberOfOps {
            blockOps.addExecutionBlock {
                var numInCirc = 0
                for _ in 0..<trialsPerOp {
                    numInCirc += Int(Point.randomInUnitRect.isInCircle)
                }
                jobResult[i] = numInCirc
                print("Operation \(i+1) done.")
            }
        }
        var inCircle = 0
        blockOps.completionBlock = {
            for i in 0..<numberOfOps {
                inCircle += jobResult[i]
            }
        }
        
        queue.addOperation(blockOps)
        queue.waitUntilAllOperationsAreFinished()
        
        // FIXME: Do 0..<leftOver computations (less than numberOfOps).
        print("Stil have \(leftOver) trials to compute.")
        
        return Double(4*inCircle)/Double(trials)
    }
    
    /// Monte Carlo pi estimation using GCD.
    public static var piEstimateGCD: Double {
        let trials = MonteGlobals.trials
        let numberOfOps = MonteGlobals.jobs
        let trialsPerOp = trials/numberOfOps
        let leftOver = trials%numberOfOps
        print("\(trials) split into \(numberOfOps) operations for \(trialsPerOp) trials each. \(leftOver) left over.")
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        var results = [Int].init(count: numberOfOps, repeatedValue: 0)
        dispatch_apply(numberOfOps, queue) { i in
            for _ in 0..<trialsPerOp {
                results[i] += Int(Point.randomInUnitRect.isInCircle)
            }
            print("Operation \(i+1) done.")
        }
        
        var inCircle = 0
        for i in 0..<numberOfOps {
            inCircle += results[i]
        }
        
        return Double(4*inCircle)/Double(trials)
    }
}