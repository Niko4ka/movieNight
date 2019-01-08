//
//  String+Extension.swift
//  Film App
//
//  Created by Вероника Данилова on 18/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import Foundation

extension String {
    
    func getYoutubeFormattedDuration() -> String {
        
        let formattedDuration = self.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")

        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            duration = duration.count > 0 ? duration + ":" : duration
            if component.count < 2 {
                duration += "0" + component
                continue
            }
            duration += component
        }
        
        if duration.hasPrefix("0") && duration.contains(":") {
            duration.removeFirst()
        } else {
            duration = "0:" + duration
        }
        
        return duration
        
    }
    
    func deletedPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: self) {
            formatter.timeStyle = .none
            formatter.dateStyle = .medium
            let formattedString = formatter.string(from: date)
            return formattedString
        } else {
            return self
        }
    }
    
    func getYear() -> String {
        let components = self.components(separatedBy: "-")
        
        if let year = components.first, year.count == 4 {
            return year
        } else {
            return ""
        }
    }
    
    func calculateCurrentAge() -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "YYYY-MM-DD"
        let birthdayDate = dateFormater.date(from: self)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
        let age = calcAge.year
        return String(describing: age!)
    }
    
}
