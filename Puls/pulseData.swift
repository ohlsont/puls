//
//  pulseData.swift
//  Puls
//
//  Created by Tomas Ohlson on 2016-12-19.
//  Copyright © 2016 Tomas Ohlson. All rights reserved.
//

import Foundation
import HealthKit

class PulseDataManager {
    let healthStore: HKHealthStore
    
    init() {
        healthStore = HKHealthStore()
    }

    func getTodaysData(callback: @escaping (_ data: [PulseData])->()) {
        let p = predicateForSamplesToday()
        getData(predicate: p, callback: callback)
    }
    
    func getData(predicate: NSPredicate, callback: @escaping (_ data: [PulseData])->()) {
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
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            let query = HKSampleQuery(sampleType: pulse, predicate: predicate, limit: limit, sortDescriptors: [sort]) { (query: HKSampleQuery, samples: [HKSample]?, error: Error?) in
                guard let samples = samples as? [HKQuantitySample], error == nil else {
                    print("query went bad")
                    return
                }
                let data = samples.map { (sample) -> PulseData in
                    let heartRateUnit = HKUnit(from: "count/min")
                    let rate = sample.quantity.doubleValue(for: heartRateUnit)
                    return PulseData(pulse: rate, start: sample.startDate)
                }
                callback(data)
            }
            self.healthStore.execute(query)
        })
    }
    
    func getOneWeekData(callback: @escaping (_ data: [Date:[PulseData]])->()) {
        let dates = self.datesFrom(daysBack: -7)
        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: dates.0, end: dates.1, options: HKQueryOptions.strictStartDate)
        getData(predicate: predicate) { (points) in
            var data = [Date:[PulseData]]()
            _ = points.map({ p in
                if let ps = data[Calendar.current.startOfDay(for: p.start)] {
                    data[Calendar.current.startOfDay(for: p.start)] = ps + [p]
                } else {
                    data[Calendar.current.startOfDay(for: p.start)] = [p]
                }
            })
            callback(data)
        }
    }
    
    private func predicateForSamplesToday() -> NSPredicate {
        let (starDate, endDate): (Date, Date) = self.datesFrom(daysBack: -1)
        
        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: starDate, end: endDate, options: HKQueryOptions.strictStartDate)
        
        return predicate
    }
    
    private func datesFrom(daysBack: Int) -> (Date, Date) {
        let calendar = Calendar.current
        
        let nowDate = Date()
        
        let starDate: Date = calendar.startOfDay(for: nowDate)
        let endDate: Date = calendar.date(byAdding: Calendar.Component.day, value: daysBack, to: starDate)!
        print("got data between \(starDate) \(endDate)")
        return (endDate, starDate)
    }
}
