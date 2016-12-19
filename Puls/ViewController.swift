//
//  ViewController.swift
//  Puls
//
//  Created by Tomas Ohlson on 2016-12-16.
//  Copyright © 2016 Tomas Ohlson. All rights reserved.
//

import UIKit

import Charts

struct PulseData {
    let pulse: Double
    let start: Date
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var pulseTable: UITableView!
    
    let pulseManager = PulseDataManager()
    var chartManager: ChartManager? = nil
    var pulseDays = [(Date,[PulseData])]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartManager = ChartManager(chart: chart)
        pulseTable.delegate = self
        pulseTable.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
        pulseManager.getTodaysData(callback: { points in
            DispatchQueue.main.async {
                self.chartManager?.fill(points: points)
            }
        })
        
        pulseManager.getOneWeekData { (dat: [Date : [PulseData]]) in
            self.pulseDays = dat.map({$0})
            DispatchQueue.main.async {
                self.pulseTable.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pulseDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dayTuple = pulseDays[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "pulseCell", for: indexPath)
        if let cell = cell as? PulseDayCell {
            cell.configure(pulseData: dayTuple.1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            
            if hexColor.characters.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

