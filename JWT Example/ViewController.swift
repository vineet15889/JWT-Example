//
//  ViewController.swift
//  JWT Example
//
//  Created by Vineet Rai on 08/04/21.
//

import UIKit
import Charts

class ViewController: UIViewController {
    let lineChartView = LineChartView()
    @IBOutlet weak var loader: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.startAnimating()
        loader.isHidden = false
        self.chartView()
        JWTHelper.shared.refreshBearer {
            self.loadHealtData()
        }
    }
    
    func chartView(){
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true

        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false

        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.legend.enabled = false
//        lineChartView.chartDescription?.text = " "
        lineChartView.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: self.view.frame.height - 100)
        lineChartView.center = self.view.center
        self.view .addSubview(lineChartView)
    }
    
    func loadHealtData(){
        JWTHelper.shared.getHealthData { (data) in
            self.loader.stopAnimating()
            self.loader.isHidden = true
            if let weightData = data as? [[String:Any]] {
                var time = [String]()
                var point = [Double]()
                for i in weightData {
                    if self.isValidData(date: i["Timestamp"]! as! String) {
                        let p:Double = i["Point"]! as! Double
                        let t:String = self.changeFormate(date: i["Timestamp"]! as! String)
                        point.append(p)
                        time.append(t)
                    }
                }
                self.chartDatat(time: time, point: point)
            }
        }
    }
    
    func chartDatat(time: [String], point: [Double]){
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<time.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: point[i], data: time[i] as AnyObject)
            dataEntries.append(dataEntry)
        }

        let chartDataSet = LineChartDataSet(entries: dataEntries, label: nil)
        chartDataSet.circleRadius = 5
        chartDataSet.circleHoleRadius = 2
        chartDataSet.drawValuesEnabled = false

        let chartData = LineChartData(dataSets: [chartDataSet])
        lineChartView.data = chartData
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: time)
        lineChartView.xAxis.setLabelCount(time.count, force: true)
        self.loader.stopAnimating()
        self.loader.isHidden = true
    }
    
    // Date Helper method
    func changeFormate(date:String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterGet.dateFormat = "yyyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d"
        if let date = dateFormatterGet.date(from:  date) {
            print(dateFormatterPrint.string(from: date))
            return dateFormatterPrint.string(from: date)
        }
        return ""
    }
    
    // Short for 2021-04-03 to 2021-04-06
    func isValidData(date:String) -> Bool{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyyy"
        let apr3 = formatter.date(from:  "Apr 3 2021")!
        let apr4 = formatter.date(from:  "Apr 7 2021")!
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterGet.dateFormat = "yyyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateForDataPoint = dateFormatterGet.date(from:  date)!
        return (dateForDataPoint.isBetween(apr3, and: apr4))
    }

}

extension Date {
    func isBetween(_ startDate: Date, and endDate: Date) -> Bool {
        return startDate <= self && self <= endDate
    }

}

