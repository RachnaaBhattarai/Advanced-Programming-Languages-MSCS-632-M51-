"Define the Ride abstract base class"
Object subclass: Ride [
    | rideID pickupLocation dropoffLocation distance baseFare status requestTime completionTime driver |
    
    "Ride class methods"
    Ride class >> new [
        "Override new to prevent direct instantiation of the abstract class"
        self == Ride ifTrue: [^self error: 'Ride is an abstract class. Create a specific type of ride.'].
        ^super new
    ]
    
    "Ride instance methods"
    initialize [
        "Initialize a new ride instance"
        rideID := 'R-', (Time millisecondClockValue printString).
        baseFare := 2.0.
        status := 'requested'.
        requestTime := Date today printString, ' ', Time now printString.
    ]
    
    rideID: anID [
        rideID := anID.
    ]
    
    rideID [
        ^rideID
    ]
    
    pickupLocation: aLocation [
        pickupLocation := aLocation.
    ]
    
    pickupLocation [
        ^pickupLocation
    ]
    
    dropoffLocation: aLocation [
        dropoffLocation := aLocation.
    ]
    
    dropoffLocation [
        ^dropoffLocation
    ]
    
    distance: aDistance [
        "Validate that distance is positive"
        aDistance > 0 
            ifTrue: [distance := aDistance]
            ifFalse: [self error: 'Distance must be positive'].
    ]
    
    distance [
        ^distance
    ]
    
    status: aStatus [
        status := aStatus.
        aStatus = 'completed' ifTrue: [
            completionTime := Date today printString, ' ', Time now printString.
        ].
    ]
    
    status [
        ^status
    ]
    
    calculateFare [
        "Abstract method to be implemented by subclasses"
        self subclassResponsibility.
    ]
    
    fare [
        "Return the calculated fare"
        ^self calculateFare
    ]
    
    rideDetails [
        "Print details of the ride"
        | details |
        details := 'Ride ID: ', rideID, 
          ', Pickup: ', pickupLocation, 
          ', Dropoff: ', dropoffLocation, 
          ', Distance: ', distance printString, ' miles', 
          ', Fare: $', self fare printString,
          ', Status: ', status.
        ^details
    ]
]

"Define StandardRide subclass"
Ride subclass: StandardRide [
    | ratePerMile |
    
    initialize [
        super initialize.
        ratePerMile := 2.0. "Standard rate per mile"
    ]
    
    ratePerMile: aRate [
        ratePerMile := aRate.
    ]
    
    ratePerMile [
        ^ratePerMile
    ]
    
    calculateFare [
        "Standard fare calculation: base fare + (rate per mile * distance)"
        ^baseFare + (ratePerMile * distance)
    ]
    
    rideDetails [
        ^(super rideDetails), ' (Standard)'
    ]
]

"Define Driver class"
Object subclass: Driver [
    | driverID name rating assignedRides location available |
    
    initialize [
        driverID := 'D-', (Time millisecondClockValue printString).
        rating := 5.0.
        assignedRides := OrderedCollection new.
        available := true.
    ]
    
    name: aName [
        name := aName.
    ]
    
    name [
        ^name
    ]
    
    rating: aRating [
        (aRating between: 1.0 and: 5.0)
            ifTrue: [rating := aRating]
            ifFalse: [self error: 'Rating must be between 1 and 5'].
    ]
    
    rating [
        ^rating
    ]
    
    addRide: aRide [
        assignedRides add: aRide.
    ]
    
    calculateTotalEarnings [
        "Calculate total earnings"
        | total |
        total := 0.
        assignedRides do: [:ride | total := total + ride fare].
        ^total
    ]
    
    getDriverInfo [
        "Driver info"
        | info |
        info := 'Driver ID: ', driverID, 
          ', Name: ', name, 
          ', Rating: ', rating printString, 
          ', Total Rides: ', assignedRides size printString,
          ', Total Earnings: $', self calculateTotalEarnings printString.
        ^info
    ]
]

"Define Rider class"
Object subclass: Rider [
    | riderID name requestedRides |
    
    initialize [
        riderID := 'C-', (Time millisecondClockValue printString).
        requestedRides := OrderedCollection new.
    ]
    
    name: aName [
        name := aName.
    ]
    
    name [
        ^name
    ]
    
    requestRide: aRide [
        requestedRides add: aRide.
        ^aRide
    ]
    
    calculateTotalSpent [
        | total |
        total := 0.
        requestedRides do: [:ride | total := total + ride fare].
        ^total
    ]
]

"Example Usage"
| alice bob dave ride1 |
Transcript show: 'Creating ride-sharing system...'; cr.

alice := Rider new.
alice name: 'Alice'.
bob := Rider new.
bob name: 'Bob'.

dave := Driver new.
dave name: 'Dave'.
dave rating: 4.8.

ride1 := StandardRide new.
ride1 pickupLocation: 'Downtown'.
ride1 dropoffLocation: 'Airport'.
ride1 distance: 10.5.

Transcript show: 'Created a standard ride: '; cr.
Transcript show: ride1 rideDetails; cr.

alice requestRide: ride1.
dave addRide: ride1.

Transcript show: 'Driver info: '; cr.
Transcript show: dave getDriverInfo; cr.
