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
    let jobsNumberList = [1, 2, 4, 8, 16]
    
    var formatterTrials = NSNumberFormatter()
    var formatterTime = NSNumberFormatter()
    var formatterError = NSNumberFormatter()

    @IBOutlet weak var labelTrials: UILabel?
    @IBOutlet weak var stepperTrials: UIStepper?
    
    @IBOutlet weak var labelJobs: UILabel?
    @IBOutlet weak var stepperJobs: UIStepper?
    
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
        formatterTime.formatWidth = 8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepperTrials?.maximumValue = Double(trialsList.count - 1)
        labelTrialsUpdate()
        stepperJobs?.maximumValue = Double(jobsNumberList.count - 1)
        labelJobsUpdate()
    }

    //MARK: Label setting
    
    func labelTrialsUpdate() {
        guard let index = stepperTrials?.intValue else {
            return
        }
        labelTrials?.text = formatterTrials.stringFromNumber(NSNumber(integer: trialsList[index]))
    }
    
    func labelJobsUpdate() {
        guard let index = stepperJobs?.intValue else {
            return
        }
        labelJobs?.text = String(jobsNumberList[index])
    }
    
    @IBAction func stepperTrialAction() {
        labelTrialsUpdate()
    }
    
    @IBAction func stepperJobsAction() {
        labelJobsUpdate()
    }
    
}
