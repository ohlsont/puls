//
//  ViewController.swift
//  Puls
//
//  Created by Tomas Ohlson on 2016-12-16.
//  Copyright © 2016 Tomas Ohlson. All rights reserved.
//

import UIKit
import HealthKit
import Charts

struct PulseData {
    let pulse: Double
    let start: Date
}

class ViewController: UIViewController {
    let healthStore: HKHealthStore = HKHealthStore()
    weak var axisFormatDelegate: IAxisValueFormatter?
    @IBOutlet weak var chart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        axisFormatDelegate = self
        // Do any additional setup after loading the view, typically from a nib.
        getData { points in
            DispatchQueue.main.async {
                self.fill(points: points)
            }
        }
    }
    
    func fill(points: [PulseData]) {
        let chartDataSet = dataSet(points: points)
        chart.legend.form = .line
        chart.data = LineChartData(dataSets: [chartDataSet])
        let xaxis = chart.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        chart.data?.notifyDataChanged()
        chart.notifyDataSetChanged()
    }
    
    func dataSet(points: [PulseData]) -> LineChartDataSet {
        let d = points.enumerated().map {ChartDataEntry(x: Double($0.offset), y: $0.element.pulse)}
        let set1: LineChartDataSet = LineChartDataSet(values: d, label: "Pulse")
        let max = points.map({$0.pulse}).max()
        let min = points.map({$0.pulse}).min()
        let xmax = points.count
        let xmin = 0
        print("max \(max), \(min) \(xmax) \(xmin)")
        return set1
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

extension ViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

extension Array {
    func takeElseAll(_ take: Int) -> Array {
        guard take > 0 else {
            return []
        }
        if self.count < take {
            return Array(self[0...self.count-1])
        } else {
            return Array(self[0...take-1])
        }
    }
}

