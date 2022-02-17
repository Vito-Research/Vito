//
//  CalanderView.swift
//  CalanderView
//
//  Created by Andreas on 9/3/21.
//

import SwiftUI

fileprivate extension DateFormatter {
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }

    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

 extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
}

struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    @ObservedObject var health: Healthv3
    @State var showData = false
    let interval: DateInterval
    let showHeaders: Bool
    let content: (Date) -> DateView

    init(
        health: Healthv3,
        interval: DateInterval,
        showHeaders: Bool = true,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.health = health
        if let earlyDate = Calendar.current.date(
            byAdding: .month,
            value: -12,
            to: Date()) {
        self.interval = DateInterval(start: earlyDate, end: Date())
        } else {
            self.interval = interval
        }
        self.showHeaders = showHeaders
        self.content = content
    }
    @State var selectedDate = 12
    var body: some View {
       // ScrollView() {
        TabView(selection: $selectedDate) {
               
            ForEach(Array(zip(months, months.indices)), id: \.1) { (month, i) in
                    VStack {
                       // header(for: month)
                           
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 30, maximum: 40)), count: 7), spacing: 0) {
            //   if month.get(.month) >= Date().get(.month) - 2 && month.get(.month) <= Date().get(.month)  {
                Section(header: header(for: month)) {
                    ForEach(days(for: month), id: \.self) { date in
                        if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                            Button(action: {
                                health.queryDate = Query(id: UUID().uuidString, durationType: .Day, duration: 1, anchorDate: date.formatted(date: .abbreviated, time: .omitted).toDate() ?? date)
                               
                                showData.toggle()
                            }) {

                            content(date).id(date)
                                .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                            } .padding()
                            .sheet(isPresented: $showData) {
                                DataView(health: health)
                            }
                        } else {
                            Button(action: {
                                health.queryDate = Query(id: UUID().uuidString, durationType: .Day, duration: 1, anchorDate: date)
                                showData.toggle()
                            }) {
                            content(date).hidden()
                                .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))

                            }

                            .sheet(isPresented: $showData) {
                                DataView(health: health)
                            }
                        }

                    }
                }
                }
                    } .tag(i)
            }
        } .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            //}
            //Spacer()

    }
    
    private var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }

    private func header(for month: Date) -> some View {
        let component = calendar.component(.month, from: month)
        let formatter = component == 1 ? DateFormatter.monthAndYear : .month

        return Group {
            if showHeaders {
                Text(formatter.string(from: month))
                    .font(.custom("Poppins-Bold", size: 18, relativeTo: .headline))
                    .padding()
            }
        }
    }

    private func days(for month: Date) -> [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month),
            let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end)
        else { return [] }
        return calendar.generateDates(
            inside: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
            matching: DateComponents(hour: 23, minute: 59, second: 0)
        )
    }
}
