//
//  ViewController.swift
//  ConcurrentPi
//
//  Created by Everett Kropf on 10/08/2016.
//  Copyright © 2016 Everett Kropf. All rights reserved.
//

import UIKit

extension UIStepper {
    var intValue: Int { return Int(self.value) }
}

class ViewController: UIViewController {
    
    let trialsList = [Int(3.5e4), Int(1e5), Int(3.5e5), Int(1e6), Int(3.5e6), Int(1e7)]
    let jobsNumberList = [2, 4, 8, 16]
    
    var formatterTrials = NSNumberFormatter()
    var formatterTime = NSNumberFormatter()
    var formatterError = NSNumberFormatter()
    
    @IBOutlet weak var labelTrials: UILabel?
    @IBOutlet weak var stepperTrials: UIStepper?
    
    @IBOutlet weak var labelJobs: UILabel?
    @IBOutlet weak var stepperJobs: UIStepper?
    
    @IBOutlet weak var labelSequentialTime: UILabel?
    @IBOutlet weak var labelSequentialError: UILabel?
    @IBOutlet weak var labelDispatchTime: UILabel?
    @IBOutlet weak var labelDispatchError: UILabel?
    
    //MARK: Lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        formatterTrials.numberStyle = .DecimalStyle
        formatterTrials.usesGroupingSeparator = true
        
        formatterError.numberStyle = .ScientificStyle
        formatterError.minimumSignificantDigits = 5
        formatterError.usesSignificantDigits = true
        
        formatterTime.numberStyle = .DecimalStyle
        formatterTime.minimumSignificantDigits = 4
        formatterTime.usesSignificantDigits = true
//        formatterTime.formatWidth = 8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepperTrials?.maximumValue = Double(trialsList.count - 1)
        labelTrialsUpdate()
        stepperJobs?.maximumValue = Double(jobsNumberList.count - 1)
        labelJobsUpdate()
        
        labelSequentialUpdate()
        labelDispatchUpdate()
    }
    
    
    @IBAction func actionRunTrials() {
        launchDispatch()
        launchSequential()
    }

    //MARK: Label setting
    
    func labelTrialsUpdate() {
        guard let index = stepperTrials?.intValue else {
            return
        }
        labelTrials?.text = formatterTrials.stringFromNumber(NSNumber(integer: trialsList[index]))
        MonteGlobals.trials = trialsList[index]
    }
    
    func labelJobsUpdate() {
        guard let index = stepperJobs?.intValue else {
            return
        }
        labelJobs?.text = String(jobsNumberList[index])
        MonteGlobals.jobs = jobsNumberList[index]
    }
    
    @IBAction func stepperTrialAction() {
        labelTrialsUpdate()
    }
    
    @IBAction func stepperJobsAction() {
        labelJobsUpdate()
    }
    
    //MARK: Serial computation
    
    var sequentialValue = 0.0
    var sequentialTime: CFTimeInterval?
    var sequentialError: Double?
    
    func launchSequential() {
        sequentialTime = CACurrentMediaTime()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.sequentialValue = Double.piEstimateSerial
            dispatch_async(dispatch_get_main_queue()) {
                self.completeSequential()
            }
        }
    }
    
    func completeSequential() {
        if let time = sequentialTime {
            sequentialTime = CACurrentMediaTime() - time
        }
        sequentialError = abs(M_PI - sequentialValue)
        labelSequentialUpdate()
    }
    
    func labelSequentialUpdate() {
        var timeString = "-.--"
        if let time = sequentialTime, str = formatterTime.stringFromNumber(NSNumber(double: time)) {
            timeString = str
        }
        labelSequentialTime?.text = timeString + " secs"
        
        var errString = "-.--E--"
        if let error = sequentialError, str = formatterError.stringFromNumber(NSNumber(double: error)) {
            errString = str
        }
        labelSequentialError?.text = errString
    }
    
    
    //MARK: Dispatch computation
    
    var dispatchValue = 0.0
    var dispatchTime: CFTimeInterval?
    var dispatchError: Double?
    
    func launchDispatch() {
        dispatchTime = CACurrentMediaTime()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            Double.piEstimateGCD(&self.dispatchValue, block: self.completeDispatch)
        }
    }
    
    func completeDispatch() {
        if let time = dispatchTime {
            dispatchTime = CACurrentMediaTime() - time
        }
        dispatchError = abs(M_PI - dispatchValue)
        labelDispatchUpdate()
    }
    
    func labelDispatchUpdate() {
        var timeString = "-.--"
        if let time = dispatchTime, str = formatterTime.stringFromNumber(NSNumber(double: time)) {
            timeString = str
        }
        labelDispatchTime?.text = timeString + " secs"
        
        var errString = "-.--E--"
        if let error = dispatchError, str = formatterError.stringFromNumber(NSNumber(double: error)) {
            errString = str
        }
        labelDispatchError?.text = errString
    }
    
}

























