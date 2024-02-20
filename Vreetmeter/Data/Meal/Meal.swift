
import Foundation
import SwiftUI

enum Meal: Int, Identifiable, CaseIterable {
    var id: Int { self.rawValue }
    
    case breakfast = 1
    case lunch = 2
    case dinner = 3
    case snack = 4
    
    func getLabel() -> String {
        switch (self) {
            case .breakfast: return "Breakfast"
            case .lunch: return "Lunch"
            case .dinner: return "Dinner"
            case .snack: return "Snack"
        }
    }
    
    func getIcon() -> String {
        switch (self) {
            case .breakfast: return "clock.fill"
            case .lunch: return "carrot.fill"
            case .dinner: return "fork.knife"
            case .snack: return "flame.fill"
        }
    }
    
    func getColor() -> Color {
        switch (self) {
            case .breakfast: return .green
            case .lunch: return .blue
            case .dinner: return .red
            case .snack: return .purple
        }
    }
    
    func getTimeOfDay(day: Date) -> (start: Date, end: Date) {
        let offset = { (offset: Int) -> Date in Calendar.current.date(byAdding: DateComponents(hour: offset), to: day.startOfDay)! }
        
        // TODO This is very subjective, maybe add some configuration options?
        switch (self) {
            case .breakfast: return (start: offset(6), end: offset(10))
            case .lunch: return (start: offset(10), end: offset(14))
            case .dinner: return (start: offset(17), end: offset(20))
            case .snack: return (start: offset(0), end: offset(24))
        }
    }
    
    public static func getAutomaticMeal(time: Date = Date.now) -> Meal {
        let time = Date.now
        let breakfast = Meal.breakfast.getTimeOfDay(day: time)
        let lunch = Meal.lunch.getTimeOfDay(day: time)
        let dinner = Meal.dinner.getTimeOfDay(day: time)
        
        if time >= breakfast.start && time < breakfast.end {
            return .breakfast
        } else if time >= lunch.start && time < lunch.end {
            return .lunch
        } else if time >= dinner.start && time < dinner.end {
            return .dinner
        }
        
        return .snack
    }
}
