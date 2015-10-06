//
//  ViewController.swift
//  WeatherApp
//
//  Created by Martyna Rysak on 22.09.2015.
//  Copyright (c) 2015 Martyna Rysak. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
let locationManager = CLLocationManager()
    var temperature : Double = 0
    var jedn = true
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var rain: UILabel!
    
    @IBOutlet weak var cityPicker: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        findLocation()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
        // Dispose of any resources that can be recreated.
    }


    func getData(urlS: String){
        
    let url = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?q=" + urlS)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in dispatch_async(dispatch_get_main_queue(), {self.setLabels(data)}) }
            
                 task.resume();
    }
 
    
    func setLabels(weatherData: NSData){
        var jsonError: NSError?
        let json = NSJSONSerialization.JSONObjectWithData(weatherData, options: nil, error: &jsonError) as! NSDictionary
        if let name = json["name"] as? String {
        cityName.text = name
        }
        
        if let main = json["main"] as? NSDictionary {
            if let temp = main["temp"] as? Double {
            temperature = temp - 273
            tempLabel.text = String(format: "%.1f", temperature)
            
            }
            if let pressure = main["pressure"] as? Int {
               
                pressureLabel.text =  "\(pressure) hPa"
            }
        }
        
        if let weather = json["weather"] as? NSArray {
 
            if let weather1 = weather[0] as? NSDictionary {

                if let description = weather1["description"] as? String{

                    rain.text = description }
                if let icon = weather1["icon"] as? String {
                    let url = NSURL(string: "http://openweathermap.org/img/w/\(icon).png")
                    let data = NSData(contentsOfURL: url!)
                    imageView.image = UIImage(data: data!)
                }
                
                
            }
            
            
            
        }
        
        
        if let sys = json["sys"] as? NSDictionary {
            if let sunrise = sys["sunrise"] as? Double {
                
                let time = NSDate(timeIntervalSince1970: sunrise)
                let timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "HH:mm a"
                var hour = timeFormatter.stringFromDate(time)
                sunriseLabel.text = "wschód: " + hour
                           }
            if let sunset = sys["sunset"] as? Double {
                
                let time = NSDate(timeIntervalSince1970: sunset)
                let timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "HH:mm a"
                var hour = timeFormatter.stringFromDate(time)
                sunsetLabel.text = "zachód: " + hour
            }
        
        }}
    
    func findLocation(){
    locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                println("error: " + error.localizedDescription)
                return
            } else {
                let pn = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pn)
            }
        
        
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark){
        self.locationManager.stopUpdatingLocation()
             getData(placemark.locality)
       
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("error: " + error.localizedDescription)
    }
    
    @IBAction func zmianaJednostki(sender: UIButton) {
        var string = "°C"
        if jedn { string = "°F"
            tempLabel.text = String(format: "%.1f", przeliczCnaF(temperature))
        } else { 
            tempLabel.text =  String(format: "%.1f", temperature)
        }
        
        jedn = !jedn
        
        sender.setTitle(string, forState: UIControlState.Normal)
        
        
    }
    func przeliczCnaF(temp: Double) -> Double {
        
        return round((temp * 9/5 + 32)*10)/10
    }
    

    @IBAction func zmianaMiasta(sender: UIButton) {
        var miasto = cityPicker.text
        if let spacja = miasto.rangeOfString(" ") {
            
        miasto.replaceRange(spacja, with: "%20")
        }
        getData(miasto)
        
        
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        if event.subtype == UIEventSubtype.MotionShake{
            findLocation()}
    }
    
    
   
    
}


