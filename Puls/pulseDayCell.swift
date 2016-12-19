//
//  pulseDayCell.swift
//  Puls
//
//  Created by Tomas Ohlson on 2016-12-18.
//  Copyright © 2016 Tomas Ohlson. All rights reserved.
//

import Foundation
import UIKit
import Charts

class PulseDayCell: UITableViewCell {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var chart: LineChartView!
    
    var chartManager: ChartManager? = nil
    
    func configure(pulseData: [PulseData]) {
        chartManager = ChartManager(chart: chart)
        chartManager?.fill(points: pulseData)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 3600)
        dateFormatter.dateFormat = "dd MMMM"
        date.text = dateFormatter.string(from: pulseData.first?.start ?? Date())
    }
}
