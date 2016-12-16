//
//  ViewController.swift
//  Puls
//
//  Created by Tomas Ohlson on 2016-12-16.
//  Copyright © 2016 Tomas Ohlson. All rights reserved.
//

import UIKit
import HealthKit

struct PulseData {
    let pulse: Double
    let start: Date
}

class ViewController: UIViewController {
    let healthStore: HKHealthStore = HKHealthStore()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getData { points in
            DispatchQueue.main.async {
                let chart = PulseChart(frame: CGRect(x: 0, y: 100, width: 300, height: 300), points: points)
                let l = Line()
                self.view.addSubview(chart.view)
                self.view.addSubview(l.view)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func getData(callback: @escaping (_ data: [PulseData])->()) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("not available")
            return
        }
        
        let pulse = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        healthStore.requestAuthorization(toShare: nil, read: [pulse], completion: { (ok, error) in
            guard error == nil else {
                print("failed getting auth")
                return
            }
            let limit: Int = Int(HKObjectQueryNoLimit)
            let predicate = self.predicateForSamplesToday()
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: pulse, predicate: predicate, limit: limit, sortDescriptors: [sort]) { (query: HKSampleQuery, samples: [HKSample]?, error: Error?) in
                guard let samples = samples as? [HKQuantitySample], error == nil else {
                    print("query went bad")
                    return
                }
                let data = samples.map { (sample) -> PulseData in
                    let heartRateUnit = HKUnit(from: "count/min")
                    let rate = sample.quantity.doubleValue(for: heartRateUnit)
                    print("data \(rate) \(sample.startDate)")
                    return PulseData(pulse: rate, start: sample.startDate)
                }
                callback(data)
            }
            self.healthStore.execute(query)
        })
    }
    
    private func predicateForSamplesToday() -> NSPredicate {
        let (starDate, endDate): (Date, Date) = self.datesFromToday()
        
        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: starDate, end: endDate, options: HKQueryOptions.strictStartDate)
        
        return predicate
    }
    
    private func datesFromToday() -> (Date, Date) {
        let calendar = Calendar.current
        
        let nowDate = Date()
        
        let starDate: Date = calendar.startOfDay(for: nowDate)
        let endDate: Date = calendar.date(byAdding: Calendar.Component.day, value: 1, to: starDate)!
        
        return (starDate, endDate)
    }
}

