//
//  BrightnessCellView.swift
//  SenStickViewer
//
//  Created by AkihiroUehara on 2016/05/25.
//  Copyright © 2016年 AkihiroUehara. All rights reserved.
//

import UIKit
import SenStickSDK

class BrightnessCellView : SensorDataCellView
{
    weak var service: BrightnessSensorService? {
        didSet {
            self.service?.delegate = self
            
            if self.service == nil {
                self.iconButton?.enabled = false
            } else {
                self.iconButton?.enabled = true
            }
        }
    }
    
    override func startToReadLog(logid: UInt8)
    {
        super.startToReadLog(logid)
        
        let logID = SensorLogID(logID: logid, skipCount: 0, position: 0)
        service?.writeLogID(logID)
    }
    
    // MARK: - SenStickSensorServiceDelegate
    override  func didUpdateSetting(sender:AnyObject)
    {
        self.iconButton?.selected = (service?.settingData?.status != .Stopping)
        
        // レンジの更新
        self.maxValue = 10000
        self.minValue = 0
        self.graphView?.maxValue = 10000
        self.graphView?.minValue = 0
        
    }
    
    override func didUpdateRealTimeData(sender: AnyObject)
    {
        if let data = service?.realtimeData {
            drawRealTimeData([data.brightness])
        }
    }
    
    override func didUpdateMetaData(sender: AnyObject)
    {
        debugPrint("\(#function), \(service!.logMetaData!.availableSampleCount)")
    }
    
    override func didUpdateLogData(sender: AnyObject)
    {
        // サンプル無し
        let sampleCount = service!.logMetaData!.availableSampleCount
        if sampleCount == 0 {
            stopReadingLog("brightness", duration: self.service?.logMetaData?.samplingDuration)
            return
        }
        
        // 終了
        if service?.logData?.count == 0 {
            stopReadingLog("brightness", duration: self.service?.logMetaData?.samplingDuration)
            return
        }
        
        // 継続
        let progress = Double(super.logData![0].count) / Double(sampleCount)
        for data in (service?.logData)! {
            addReadLog([data.brightness], progress: progress)
        }
        //        debugPrint("\(#function), progress: \(progress), super.logData!.count\(super.logData![0].count) sampleCount:\(sampleCount)")
    }
    
    // MARK: - Event handler
    @IBAction func  iconButtonToutchUpInside(sender: UIButton) {
        let status :SenStickStatus = iconButton!.selected ? .Stopping : .SensingAndLogging
        
        let current_setting = self.service!.settingData!
        let setting = SensorSettingData<BrightnessRange>(status: status, samplingDuration: current_setting.samplingDuration, range: current_setting.range)
        service?.writeSetting(setting)
    }
}
