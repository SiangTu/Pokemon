//
//  EventKitHelper.swift
//  Pokemon
//
//  Created on 2025/12/4.
//

import EventKit
import Foundation

// MARK: - EventKitError
enum EventKitError: LocalizedError {
    case accessDenied
    case accessRestricted
    case calendarNotFound
    case eventNotFound
    case reminderNotFound
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "日曆存取被拒絕，請在設定中開啟權限"
        case .accessRestricted:
            return "日曆存取受到限制"
        case .calendarNotFound:
            return "找不到指定的日曆"
        case .eventNotFound:
            return "找不到指定的事件"
        case .reminderNotFound:
            return "找不到指定的提醒事項"
        case .saveFailed(let error):
            return "儲存失敗: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "刪除失敗: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "取得資料失敗: \(error.localizedDescription)"
        case .unknown:
            return "發生未知錯誤"
        }
    }
}

// MARK: - EventKitHelper
final class EventKitHelper {
    
    // MARK: - Singleton
    static let shared = EventKitHelper()
    
    // MARK: - Properties
    private let eventStore = EKEventStore()
    
    private init() {}
    
    // MARK: - Authorization
    
    /// 請求日曆事件權限
    func requestCalendarAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }
    
    /// 請求提醒事項權限
    func requestRemindersAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToReminders()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .reminder) { granted, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }
    
    /// 檢查日曆權限狀態
    var calendarAuthorizationStatus: EKAuthorizationStatus {
        if #available(iOS 17.0, *) {
            return EKEventStore.authorizationStatus(for: .event)
        } else {
            return EKEventStore.authorizationStatus(for: .event)
        }
    }
    
    /// 檢查提醒事項權限狀態
    var remindersAuthorizationStatus: EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .reminder)
    }
    
    // MARK: - Calendars
    
    /// 取得所有日曆
    func getAllCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    
    /// 取得預設日曆
    func getDefaultCalendar() -> EKCalendar? {
        return eventStore.defaultCalendarForNewEvents
    }
    
    /// 取得所有提醒事項日曆
    func getAllReminderCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .reminder)
    }
    
    /// 取得預設提醒事項日曆
    func getDefaultReminderCalendar() -> EKCalendar? {
        return eventStore.defaultCalendarForNewReminders()
    }
    
    // MARK: - Events (日曆事件)
    
    /// 創建日曆事件
    /// - Parameters:
    ///   - title: 事件標題
    ///   - startDate: 開始日期
    ///   - endDate: 結束日期
    ///   - notes: 備註（可選）
    ///   - location: 地點（可選）
    ///   - calendar: 日曆（可選，預設使用預設日曆）
    ///   - alarmMinutesBefore: 提前幾分鐘提醒（可選）
    /// - Returns: 創建的事件識別碼
    @discardableResult
    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        notes: String? = nil,
        location: String? = nil,
        calendar: EKCalendar? = nil,
        alarmMinutesBefore: Int? = nil
    ) throws -> String {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.location = location
        event.calendar = calendar ?? eventStore.defaultCalendarForNewEvents
        
        if let minutes = alarmMinutesBefore {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-minutes * 60))
            event.addAlarm(alarm)
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return event.eventIdentifier
        } catch {
            throw EventKitError.saveFailed(error)
        }
    }
    
    /// 創建全天事件
    @discardableResult
    func createAllDayEvent(
        title: String,
        date: Date,
        notes: String? = nil,
        calendar: EKCalendar? = nil
    ) throws -> String {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = date
        event.endDate = date
        event.isAllDay = true
        event.notes = notes
        event.calendar = calendar ?? eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return event.eventIdentifier
        } catch {
            throw EventKitError.saveFailed(error)
        }
    }
    
    /// 取得指定日期範圍內的事件
    func fetchEvents(from startDate: Date, to endDate: Date, calendars: [EKCalendar]? = nil) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )
        return eventStore.events(matching: predicate)
    }
    
    /// 取得今天的所有事件
    func fetchTodayEvents(calendars: [EKCalendar]? = nil) -> [EKEvent] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return fetchEvents(from: startOfDay, to: endOfDay, calendars: calendars)
    }
    
    /// 取得本週的所有事件
    func fetchThisWeekEvents(calendars: [EKCalendar]? = nil) -> [EKEvent] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        return fetchEvents(from: startOfWeek, to: endOfWeek, calendars: calendars)
    }
    
    /// 根據識別碼取得事件
    func fetchEvent(withIdentifier identifier: String) -> EKEvent? {
        return eventStore.event(withIdentifier: identifier)
    }
    
    /// 更新事件
    func updateEvent(
        identifier: String,
        title: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        notes: String? = nil,
        location: String? = nil
    ) throws {
        guard let event = eventStore.event(withIdentifier: identifier) else {
            throw EventKitError.eventNotFound
        }
        
        if let title = title { event.title = title }
        if let startDate = startDate { event.startDate = startDate }
        if let endDate = endDate { event.endDate = endDate }
        if let notes = notes { event.notes = notes }
        if let location = location { event.location = location }
        
        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            throw EventKitError.saveFailed(error)
        }
    }
    
    /// 刪除事件
    func deleteEvent(identifier: String) throws {
        guard let event = eventStore.event(withIdentifier: identifier) else {
            throw EventKitError.eventNotFound
        }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
        } catch {
            throw EventKitError.deleteFailed(error)
        }
    }
    
    /// 刪除事件（含重複事件）
    func deleteEvent(identifier: String, deleteAllOccurrences: Bool) throws {
        guard let event = eventStore.event(withIdentifier: identifier) else {
            throw EventKitError.eventNotFound
        }
        
        let span: EKSpan = deleteAllOccurrences ? .futureEvents : .thisEvent
        
        do {
            try eventStore.remove(event, span: span)
        } catch {
            throw EventKitError.deleteFailed(error)
        }
    }
    
    // MARK: - Reminders (提醒事項)
    
    /// 創建提醒事項
    /// - Parameters:
    ///   - title: 標題
    ///   - notes: 備註（可選）
    ///   - dueDate: 到期日期（可選）
    ///   - priority: 優先級 0-9，0 為無優先級，1 最高，9 最低
    ///   - calendar: 日曆（可選）
    /// - Returns: 提醒事項識別碼
    @discardableResult
    func createReminder(
        title: String,
        notes: String? = nil,
        dueDate: Date? = nil,
        priority: Int = 0,
        calendar: EKCalendar? = nil
    ) throws -> String {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.priority = priority
        reminder.calendar = calendar ?? eventStore.defaultCalendarForNewReminders()
        
        if let dueDate = dueDate {
            let dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
            reminder.dueDateComponents = dueDateComponents
            
            // 在到期時間提醒
            let alarm = EKAlarm(absoluteDate: dueDate)
            reminder.addAlarm(alarm)
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            return reminder.calendarItemIdentifier
        } catch {
            throw EventKitError.saveFailed(error)
        }
    }
    
    /// 取得所有未完成的提醒事項
    func fetchIncompleteReminders(calendars: [EKCalendar]? = nil) async throws -> [EKReminder] {
        let predicate = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: nil,
            calendars: calendars
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }
    }
    
    /// 取得所有已完成的提醒事項
    func fetchCompletedReminders(calendars: [EKCalendar]? = nil) async throws -> [EKReminder] {
        let predicate = eventStore.predicateForCompletedReminders(
            withCompletionDateStarting: nil,
            ending: nil,
            calendars: calendars
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }
    }
    
    /// 取得指定日期範圍內的提醒事項
    func fetchReminders(from startDate: Date?, to endDate: Date?, calendars: [EKCalendar]? = nil) async throws -> [EKReminder] {
        let predicate = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: startDate,
            ending: endDate,
            calendars: calendars
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }
    }
    
    /// 根據識別碼取得提醒事項
    func fetchReminder(withIdentifier identifier: String) -> EKReminder? {
        return eventStore.calendarItem(withIdentifier: identifier) as? EKReminder
    }
    
    /// 標記提醒事項為已完成
    func completeReminder(identifier: String) throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            throw EventKitError.reminderNotFound
        }
        
        reminder.isCompleted = true
        reminder.completionDate = Date()
        
        do {
            try eventStore.save(reminder, commit: true)
        } catch {
            throw EventKitError.saveFailed(error)
        }
    }
    
    /// 標記提醒事項為未完成
    func uncompleteReminder(identifier: String) throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            throw EventKitError.reminderNotFound
        }
        
        reminder.isCompleted = false
        reminder.completionDate = nil
        
        do {
            try eventStore.save(reminder, commit: true)
        } catch {
            throw EventKitError.saveFailed(error)
        }
    }
    
    /// 更新提醒事項
    func updateReminder(
        identifier: String,
        title: String? = nil,
        notes: String? = nil,
        dueDate: Date? = nil,
        priority: Int? = nil
    ) throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            throw EventKitError.reminderNotFound
        }
        
        if let title = title { reminder.title = title }
        if let notes = notes { reminder.notes = notes }
        if let priority = priority { reminder.priority = priority }
        if let dueDate = dueDate {
            let dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: dueDate
            )
            reminder.dueDateComponents = dueDateComponents
        }
        
        do {
            try eventStore.save(reminder, commit: true)
        } catch {
            throw EventKitError.saveFailed(error)
        }
    }
    
    /// 刪除提醒事項
    func deleteReminder(identifier: String) throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder else {
            throw EventKitError.reminderNotFound
        }
        
        do {
            try eventStore.remove(reminder, commit: true)
        } catch {
            throw EventKitError.deleteFailed(error)
        }
    }
    
    // MARK: - Recurring Events (重複事件)
    
    /// 創建重複事件
    /// - Parameters:
    ///   - title: 事件標題
    ///   - startDate: 開始日期
    ///   - endDate: 結束日期
    ///   - recurrenceRule: 重複規則
    ///   - calendar: 日曆（可選）
    /// - Returns: 事件識別碼
    @discardableResult
    func createRecurringEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        recurrenceRule: EKRecurrenceRule,
        notes: String? = nil,
        calendar: EKCalendar? = nil
    ) throws -> String {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = calendar ?? eventStore.defaultCalendarForNewEvents
        event.addRecurrenceRule(recurrenceRule)
        
        do {
            try eventStore.save(event, span: .futureEvents)
            return event.eventIdentifier
        } catch {
            throw EventKitError.saveFailed(error)
        }
    }
    
    /// 創建每日重複規則
    func dailyRecurrenceRule(interval: Int = 1, endDate: Date? = nil) -> EKRecurrenceRule {
        let end = endDate.map { EKRecurrenceEnd(end: $0) }
        return EKRecurrenceRule(
            recurrenceWith: .daily,
            interval: interval,
            end: end
        )
    }
    
    /// 創建每週重複規則
    func weeklyRecurrenceRule(
        interval: Int = 1,
        daysOfWeek: [EKRecurrenceDayOfWeek]? = nil,
        endDate: Date? = nil
    ) -> EKRecurrenceRule {
        let end = endDate.map { EKRecurrenceEnd(end: $0) }
        return EKRecurrenceRule(
            recurrenceWith: .weekly,
            interval: interval,
            daysOfTheWeek: daysOfWeek,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            end: end
        )
    }
    
    /// 創建每月重複規則
    func monthlyRecurrenceRule(
        interval: Int = 1,
        daysOfMonth: [NSNumber]? = nil,
        endDate: Date? = nil
    ) -> EKRecurrenceRule {
        let end = endDate.map { EKRecurrenceEnd(end: $0) }
        return EKRecurrenceRule(
            recurrenceWith: .monthly,
            interval: interval,
            daysOfTheWeek: nil,
            daysOfTheMonth: daysOfMonth,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            end: end
        )
    }
    
    /// 創建每年重複規則
    func yearlyRecurrenceRule(interval: Int = 1, endDate: Date? = nil) -> EKRecurrenceRule {
        let end = endDate.map { EKRecurrenceEnd(end: $0) }
        return EKRecurrenceRule(
            recurrenceWith: .yearly,
            interval: interval,
            end: end
        )
    }
}

// MARK: - Convenience Extensions
extension EventKitHelper {
    
    /// 快速創建一小時的事件
    @discardableResult
    func createOneHourEvent(
        title: String,
        startDate: Date,
        notes: String? = nil,
        alarmMinutesBefore: Int? = 15
    ) throws -> String {
        let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)!
        return try createEvent(
            title: title,
            startDate: startDate,
            endDate: endDate,
            notes: notes,
            alarmMinutesBefore: alarmMinutesBefore
        )
    }
    
    /// 快速創建明天的提醒事項
    @discardableResult
    func createTomorrowReminder(title: String, notes: String? = nil) throws -> String {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let nineAM = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow)!
        return try createReminder(title: title, notes: notes, dueDate: nineAM)
    }
    
    /// 搜尋事件（根據標題）
    func searchEvents(keyword: String, from startDate: Date, to endDate: Date) -> [EKEvent] {
        let allEvents = fetchEvents(from: startDate, to: endDate)
        return allEvents.filter { event in
            event.title?.localizedCaseInsensitiveContains(keyword) ?? false
        }
    }
}

