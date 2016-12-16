//
//  chart.swift
//  Puls
//
//  Created by Tomas Ohlson on 2016-12-16.
//  Copyright © 2016 Tomas Ohlson. All rights reserved.
//

import Foundation
import SwiftCharts

class PulseChart: Chart {
    static let font = UIFont.systemFont(ofSize: 14)
    static var chartSettings: ChartSettings {
        let chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        chartSettings.trailing = 80
        return chartSettings
    }
    
    init(frame: CGRect, points: [PulseData]) {
        let labelSettings = ChartLabelSettings(font: PulseChart.font)
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd.MM.yyyy"
        
        // points
        let xValues = points.map({PulseChart.createDateAxisValue(date: $0.start, displayFormatter: displayFormatter)})
        let chartPoints = points.map({PulseChart.createChartPoint(percent: $0.pulse, date: $0.start, displayFormatter: displayFormatter)})
        let yValues = stride(from: 0, through: 100, by: 10).map {ChartAxisValuePercent($0, labelSettings: labelSettings)}
        yValues.first?.hidden = true
        
        //
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        let chartFrame = PulseChart.chartFrame(frame)
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: PulseChart.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        print("\(chartPoints.count) points")
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.red, animDuration: 1, animDelay: 0)
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
        
        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth:  0.1)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
        
        let layers: [ChartLayer] = [
            coordsSpace.xAxis,
            coordsSpace.yAxis,
            guidelinesLayer,
            chartPointsLineLayer]

        let view = ChartBaseView(frame: chartFrame)
        view.backgroundColor = .blue
        super.init(view: view, layers: layers)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func chartFrame(_ containerBounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 70, width: containerBounds.size.width, height: containerBounds.size.height - 70)
    }
    
    static func createChartPoint(percent: Double, date: Date, displayFormatter: DateFormatter) -> ChartPoint {
        return ChartPoint(x: createDateAxisValue(date: date, displayFormatter: displayFormatter), y: ChartAxisValuePercent(percent))
    }
    
    static func createDateAxisValue(date: Date, displayFormatter: DateFormatter) -> ChartAxisValue {
        let labelSettings = ChartLabelSettings(font: font, rotation: 45, rotationKeep: .top)
        return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
    }

    class ChartAxisValuePercent: ChartAxisValueDouble {
        override var description: String {
            return "\(self.formatter.string(from: NSNumber(value: self.scalar))!)%"
        }
    }
}

class Line: LineChart {
    init() {
        let chartConfig = ChartConfigXY(
            xAxisConfig: ChartAxisConfig(from: 2, to: 14, by: 2),
            yAxisConfig: ChartAxisConfig(from: 0, to: 14, by: 2)
        )
        
        let lines = [
            (chartPoints: [(2.0, 10.6), (4.2, 5.1), (7.3, 3.0), (8.1, 5.5), (14.0, 8.0)], color: UIColor.red),
            (chartPoints: [(2.0, 2.6), (4.2, 4.1), (7.3, 1.0), (8.1, 11.5), (14.0, 3.0)], color: UIColor.blue)
        ]
        
        super.init(frame: CGRect(x: 0, y: 70, width: 300, height: 500), chartConfig: chartConfig, xTitle: "time", yTitle: "pulse", lines: lines)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
