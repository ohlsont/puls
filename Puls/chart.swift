import Charts

class ChartManager: NSObject {
    let chart: LineChartView
    weak var axisFormatDelegate: IAxisValueFormatter?
    var points = [PulseData]()
    
    init(chart: LineChartView) {
        self.chart = chart
        super.init()
        axisFormatDelegate = self
    }
    
    func fill(points: [PulseData]) {
        guard points.count > 0 else {
            return
        }
        let chartDataSet = dataSet(points: points)
        //chartDataSet.colors = ChartColorTemplates.colorful()
        chartDataSet.fillAlpha = 1
        chartDataSet.drawFilledEnabled = false
        chartDataSet.drawCircleHoleEnabled = false
        chartDataSet.circleRadius = 1
        
        chart.legend.form = .line
        chart.data = LineChartData(dataSets: [chartDataSet])
        let xaxis = chart.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        chart.data?.notifyDataChanged()
        chart.notifyDataSetChanged()
    }
    
    func dataSet(points: [PulseData]) -> LineChartDataSet {
        self.points = points 
        let d = points.enumerated().map {ChartDataEntry(x: Double($0.offset), y: $0.element.pulse)}
        let set1: LineChartDataSet = LineChartDataSet(values: d, label: "Pulse")
        print("max \(set1.yMax), \(set1.yMin) \(set1.xMax) \(set1.xMin)")
        return set1
    }
}

extension ChartManager: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 3600)
        dateFormatter.dateFormat = "HH:mm"
        let index = Int(value)-1
        guard index >= 0 && index < points.count else {
            return "no value"
        }
        
        return dateFormatter.string(from: self.points[index].start)
    }
}
