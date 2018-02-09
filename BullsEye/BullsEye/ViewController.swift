//
//  ViewController.swift
//  BullsEye
//
//  Created by Vale Calderon  on 3/21/17.
//  Copyright © 2017 Vale Calderon . All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    
    var sliderCurrentValue: Int = 0
    var targetValue: Int = 0
    var score: Int = 0
    var round: Int = 0
    
    @IBOutlet weak var slider: UISlider! //Slider from the storyboard
    @IBOutlet weak var targetLabel: UILabel! //Label from the storyboard
    @IBOutlet weak var scoreLabel: UILabel!  //Score Label from the storyboard
    @IBOutlet weak var roundLabel: UILabel!  //Round Label from the storyboard

    override func viewDidLoad() {
        super.viewDidLoad()
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")!
        slider.setThumbImage(thumbImageNormal, for: .normal)
        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")!
        slider.setThumbImage(thumbImageHighlighted, for: .highlighted)
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        let trackLeftImage = UIImage(named: "SliderTrackLeft")!
        let trackLeftResizable =
            trackLeftImage.resizableImage(withCapInsets: insets)
        slider.setMinimumTrackImage(trackLeftResizable, for: .normal)
        let trackRightImage = UIImage(named: "SliderTrackRight")!
        let trackRightResizable =
            trackRightImage.resizableImage(withCapInsets: insets)
        slider.setMaximumTrackImage(trackRightResizable, for: .normal)
        startNewRound()
        updateLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    /*
        @name: showAlert
        @description: shows an alert that displays the current value of the slider, when press OK start a new round
    */
    @IBAction func showAlert() {
        let points: Int = calculatePoints()
        let message: String = "You scored \(points) points"
        let titleAlert: String = getTitleAlert(pTotalPoints: points)
        
        let alert = UIAlertController(title: titleAlert, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: {action in
                                                                                self.startNewRound()
                                                                                self.updateLabels()
                                                                          })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    /*
        @name: getTitleAlert
        @description: depending on the score of the player the alert is going to show a different kind of title
    */
    func getTitleAlert(pTotalPoints: Int) -> String{
        if(pTotalPoints == 100){
           return "Perfect!"
        }
        else if(pTotalPoints >= 95){
            return "You almost had it!"
        }
        else if(pTotalPoints >= 90 ){
            return "Pretty Good!"
        }
        else{
            return "Not even close"
        }
    }
    
    /*
        @name: sliderMoved
        @description: Action trigger everytime the slider is moved, sets the new current value of the slider in the variable sliderCurrentValue
 
    */
    @IBAction func sliderMoved(_ slider: UISlider) {
        sliderCurrentValue = lroundf(slider.value)
    }
    
    /*
        @name: startNewRound
        sets a new random number to target value
        sets the slider value to 50
     
     */
    func startNewRound() {
        targetValue = 1 + Int(arc4random_uniform(100)) //Set a random number from 1 to 100 to the variable targetValue
        sliderCurrentValue = 50
        slider.value = Float(sliderCurrentValue)
        round += 1
    }
    
    /*
        @name updateLabels
        sets the value from the targetValue to the label targetLabel from the storyboard
     
     */
    func updateLabels() {
        targetLabel.text = String(targetValue)
        scoreLabel.text = String(score)
        roundLabel.text = String(round)
    }
    
    /*
        @name: calculatePoints
        @description: calculate the points the user gets depending on the difference between the value of the slider and the target value
    */
    func calculatePoints() -> Int{
        let difference = abs(sliderCurrentValue - targetValue)
        let points = 100 - difference
        score += points
        return points
    }
    
    /*
        @name: startNewGame
        @description: sets the rounds, score, labels, slider to start a new game
     */
     @IBAction func startNewGame(){
        score = 0
        round = 0
        self.startNewRound()
        self.updateLabels()
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
            view.layer.add(transition, forKey: nil)
    }
}



