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
    
    @IBOutlet weak var labelSerialTime: UILabel?
    @IBOutlet weak var labelSerialError: UILabel?
    @IBOutlet weak var activitySerial: UIActivityIndicatorView?
    @IBOutlet weak var labelDispatchTime: UILabel?
    @IBOutlet weak var labelDispatchError: UILabel?
    @IBOutlet weak var activityDispatch: UIActivityIndicatorView?
    
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
        
        labelSerialUpdate()
        labelDispatchUpdate()
    }
    
    
    @IBAction func actionRunTrials() {
        launchDispatch()
        launchSerial()
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
    
    var serialValue = 0.0
    var serialTime: CFTimeInterval?
    var serialError: Double?
    
    func launchSerial() {
        serialTime = nil
        serialError = nil
        labelSerialUpdate()
        
        activitySerial?.startAnimating()
        serialTime = CACurrentMediaTime()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            self.serialValue = Double.piEstimateSerial
            dispatch_async(dispatch_get_main_queue()) {
                self.completeSerial()
            }
        }
    }
    
    func completeSerial() {
        activitySerial?.stopAnimating()
        if let time = serialTime {
            serialTime = CACurrentMediaTime() - time
        }
        serialError = abs(M_PI - serialValue)
        labelSerialUpdate()
    }
    
    func labelSerialUpdate() {
        var timeString = "-.--"
        if let time = serialTime, str = formatterTime.stringFromNumber(NSNumber(double: time)) {
            timeString = str
        }
        labelSerialTime?.text = timeString + " secs"
        
        var errString = "-.--E--"
        if let error = serialError, str = formatterError.stringFromNumber(NSNumber(double: error)) {
            errString = str
        }
        labelSerialError?.text = errString
    }
    
    
    //MARK: Dispatch computation
    
    var dispatchValue = 0.0
    var dispatchTime: CFTimeInterval?
    var dispatchError: Double?
    
    func launchDispatch() {
        dispatchTime = nil
        dispatchError = nil
        labelDispatchUpdate()
        
        activityDispatch?.startAnimating()
        dispatchTime = CACurrentMediaTime()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            Double.piEstimateGCD(&self.dispatchValue, block: self.completeDispatch)
        }
    }
    
    func completeDispatch() {
        activityDispatch?.stopAnimating()
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

























