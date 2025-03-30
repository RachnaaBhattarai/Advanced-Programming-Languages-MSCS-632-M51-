"Define the Ride abstract base class"
Object subclass: #Ride
    instanceVariableNames: 'rideID pickupLocation dropoffLocation distance baseFare'
    classVariableNames: ''
    package: 'RideSharingSystem'.

"Ride class methods"
Ride class >> new
    "Override new to prevent direct instantiation of the abstract class"
    self == Ride ifTrue: [self error: 'Ride is an abstract class. Create a specific type of ride.'].
    ^super new

"Ride instance methods"
Ride >> initialize
    "Initialize a new ride instance"
    super initialize.
    rideID := UUID new asString.
    baseFare := 0.0.

Ride >> rideID: anID
    rideID := anID.

Ride >> rideID
    ^rideID.

Ride >> pickupLocation: aLocation
    pickupLocation := aLocation.

Ride >> pickupLocation
    ^pickupLocation.

Ride >> dropoffLocation: aLocation
    dropoffLocation := aLocation.

Ride >> dropoffLocation
    ^dropoffLocation.

Ride >> distance: aDistance
    distance := aDistance.

Ride >> distance
    ^distance.

Ride >> calculateFare
    "Abstract method to be implemented by subclasses"
    self subclassResponsibility.

Ride >> fare
    "Return the calculated fare"
    ^self calculateFare.

Ride >> rideDetails
    "Print details of the ride"
    ^'Ride ID: ', rideID, 
      ', Pickup: ', pickupLocation, 
      ', Dropoff: ', dropoffLocation, 
      ', Distance: ', distance asString, ' miles', 
      ', Fare: $', self fare asString.

"Define StandardRide subclass"
Ride subclass: #StandardRide
    instanceVariableNames: 'ratePerMile'
    classVariableNames: ''
    package: 'RideSharingSystem'.

"StandardRide instance methods"
StandardRide >> initialize
    super initialize.
    ratePerMile := 2.0. "Standard rate per mile"

StandardRide >> ratePerMile: aRate
    ratePerMile := aRate.

StandardRide >> ratePerMile
    ^ratePerMile.

StandardRide >> calculateFare
    "Standard fare calculation: base fare + (rate per mile * distance)"
    ^2.0 + (ratePerMile * distance).

StandardRide >> rideDetails
    ^super rideDetails, ' (Standard)'.

"Define PremiumRide subclass"
Ride subclass: #PremiumRide
    instanceVariableNames: 'ratePerMile luxuryFee'
    classVariableNames: ''
    package: 'RideSharingSystem'.

"PremiumRide instance methods"
PremiumRide >> initialize
    super initialize.
    ratePerMile := 3.5.
    luxuryFee := 5.0.

PremiumRide >> ratePerMile: aRate
    ratePerMile := aRate.

PremiumRide >> ratePerMile
    ^ratePerMile.

PremiumRide >> luxuryFee: aFee
    luxuryFee := aFee.

PremiumRide >> luxuryFee
    ^luxuryFee.

PremiumRide >> calculateFare
    "Premium fare calculation"
    ^2.0 + luxuryFee + (ratePerMile * distance).

PremiumRide >> rideDetails
    ^super rideDetails, ' (Premium)'.

"Define SharedRide subclass"
Ride subclass: #SharedRide
    instanceVariableNames: 'ratePerMile numberOfRiders'
    classVariableNames: ''
    package: 'RideSharingSystem'.

"SharedRide instance methods"
SharedRide >> initialize
    super initialize.
    ratePerMile := 1.5.
    numberOfRiders := 1.

SharedRide >> ratePerMile: aRate
    ratePerMile := aRate.

SharedRide >> ratePerMile
    ^ratePerMile.

SharedRide >> numberOfRiders: aNumber
    numberOfRiders := aNumber.

SharedRide >> numberOfRiders
    ^numberOfRiders.

SharedRide >> calculateFare
    "Shared fare calculation"
    ^(2.0 + (ratePerMile * distance)) / numberOfRiders.

SharedRide >> rideDetails
    ^super rideDetails, ' (Shared, Riders: ', numberOfRiders asString, ')'.


"Define Driver class"
Object subclass: #Driver
    instanceVariableNames: 'driverID name rating assignedRides'
    classVariableNames: ''
    package: 'RideSharingSystem'.

"Driver instance methods"
Driver >> initialize
    super initialize.
    driverID := UUID new asString.
    rating := 5.0.
    assignedRides := OrderedCollection new.

Driver >> driverID: anID
    driverID := anID.

Driver >> driverID
    ^driverID.

Driver >> name: aName
    name := aName.

Driver >> name
    ^name.

Driver >> rating: aRating
    rating := aRating.

Driver >> rating
    ^rating.

Driver >> addRide: aRide
    assignedRides add: aRide.

Driver >> getAssignedRides
    ^assignedRides copy.

Driver >> calculateTotalEarnings
    "Calculate total earnings"
    | total |
    total := 0.
    assignedRides do: [:ride | total := total + ride fare].
    ^total.

Driver >> getDriverInfo
    "Driver info"
    ^'Driver ID: ', driverID, 
      ', Name: ', name, 
      ', Rating: ', rating asString, 
      ', Total Rides: ', assignedRides size asString,
      ', Total Earnings: $', self calculateTotalEarnings asString.

"Define Rider class"
Object subclass: #Rider
    instanceVariableNames: 'riderID name requestedRides'
    classVariableNames: ''
    package: 'RideSharingSystem'.

"Rider instance methods"
Rider >> initialize
    super initialize.
    riderID := UUID new asString.
    requestedRides := OrderedCollection new.

Rider >> riderID: anID
    riderID := anID.

Rider >> riderID
    ^riderID.

Rider >> name: aName
    name := aName.

Rider >> name
    ^name.

Rider >> requestRide: aRide
    requestedRides add: aRide.
    ^aRide.

Rider >> viewRides
    | result |
    result := 'Rides for ', name, ' (', riderID, '):', String cr.
    requestedRides do: [:ride | 
        result := result, ride rideDetails, String cr.
    ].
    result := result, 'Total Spent: $', self calculateTotalSpent asString.
    ^result.

Rider >> calculateTotalSpent
    | total |
    total := 0.
    requestedRides do: [:ride | total := total + ride fare].
    ^total.

"Example Usage"
| system |
system := Dictionary new.

system at: #rider1 put: (Rider new name: 'Alice').
system at: #rider2 put: (Rider new name: 'Bob').

system at: #driver1 put: (Driver new name: 'Dave'; rating: 4.8).
system at: #driver2 put: (Driver new name: 'Eve'; rating: 4.9).

system at: #ride1 put: (StandardRide new pickupLocation: 'Downtown'; dropoffLocation: 'Airport'; distance: 10.5).
system at: #ride2 put: (PremiumRide new pickupLocation: 'Airport'; dropoffLocation: 'Hotel'; distance: 8.2).

"Output Information"
Transcript show: (system at: #rider1) viewRides; cr.
