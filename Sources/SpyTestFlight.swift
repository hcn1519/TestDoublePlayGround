import Foundation

public struct Flight {
    public let number: Int

    public init(number: Int) {
        self.number = number
    }
}

public protocol FlightManagable {
    var flights: [Flight] { get set }
    var controlTower: FlightReportable { get set }
    mutating func removeFlight(number: Int)
    func hasFlight(number: Int) -> Bool
}

public protocol FlightReportable {
    var notifications: [ControlTower.Notification] { get }
    mutating func report(date: Date, actionCode: String, detail: Any?)
}

public struct ControlTower: FlightReportable {
    public struct Notification {
        public var date: Date
        public var actionCode: String
        public var detail: Any?
    }

    public var notifications: [ControlTower.Notification] = []

    public init() {
        self.notifications = []
    }

    public mutating func report(date: Date, actionCode: String, detail: Any?) {
        let notification = ControlTower.Notification(date: date, actionCode: actionCode, detail: detail)
        self.notifications.append(notification)
    }
}

public struct ControlTowerSpy: FlightReportable {
    public var notifications: [ControlTower.Notification]
    public var numberOfReports: Int = 0

    public init() {
        self.notifications = []
        self.numberOfReports = 0
    }

    public mutating func report(date: Date, actionCode: String, detail: Any?) {
        let notification = ControlTower.Notification(date: date,
                                                     actionCode: actionCode,
                                                     detail: detail)
        self.notifications.append(notification)
        self.numberOfReports += 1
    }
}

public struct Airport: FlightManagable {
    public var flights: [Flight] = []
    public var controlTower: FlightReportable

    public init(flights: [Flight], controlTower: FlightReportable) {
        self.flights = flights
        self.controlTower = controlTower
    }

    public mutating func addFlights(_ flights: [Flight]) {
        self.flights.append(contentsOf: flights)
        controlTower.report(date: Date(), actionCode: "add(flights:)", detail: nil)
    }

    public mutating func removeFlight(number: Int) {
        let filteredFlight = flights.filter { $0.number != number }
        self.flights = filteredFlight
        controlTower.report(date: Date(), actionCode: "remove(number:)", detail: number)
    }

    public func hasFlight(number: Int) -> Bool {
        return flights.contains(where: { $0.number == number })
    }
}
