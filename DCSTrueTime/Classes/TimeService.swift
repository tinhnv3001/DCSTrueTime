//
//  TimeService.swift
//  DCSTrueTime
//
//  Created by iMac on 27/04/2021.
//

import Foundation

// 1.0.1
// Lớp Đồng bộ thời gian từ phía Server
public class TimeService{
   public static let shared = TimeService()
    var startTime = Date()
    var delay = 0.0
    var serverTime = Date()
    let timeIP =  URL(string: "https://api.diachiso.vn/utils/gettime")!
    // Đồng bộ Time từ phía sever
    // Phương thức này sẽ gọi lần đầu mỗi khi mở ứng dụng
    public func asyncTimeFromServer(completion: @escaping ((String?, Error?)-> Void)){
        URLSession.shared.dataTask(with: timeIP) { data, response, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            do {
                self.delay = Date() - self.startTime
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let svTime = try decoder.decode(ServerTime.self, from: data)

                self.serverTime = Date.convertStringToDate(isoDate: svTime.iso8601)
                print(self.serverTime)
                
                completion(svTime.iso8601, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    // Phương thức này sẽ gọi thời gian thực đã được đồng bộ từ trên phía server
  public  func getDateTime() -> String{
        let timeNow = serverTime + (Date() - startTime - (delay / 2))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
       return  dateFormatter.string(from: timeNow)
    }
    
}


struct ServerTime: Codable {
    let iso8601: String
}

extension Date {
   public static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
  public  static func + (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate + rhs.timeIntervalSinceReferenceDate
    }
    
  public  static func convertStringToDate(isoDate: String) -> Date{
         let dateFormatter = DateFormatter()
         //dateFormatter.locale = Locale.current // set locale to reliable US_POSIX
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
         dateFormatter.locale = Locale(identifier: "en_US_POSIX")
         let date = dateFormatter.date(from:isoDate)!
         return date
     }

}

