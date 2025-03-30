"Define the Ride abstract base class"
Object subclass: #Ride
    instanceVariableNames: 'rideID pickupLocation dropoffLocation distance baseFare status requestTime completionTime driver'
    classVariableNames: ''
    package: 'RideSharingSystem'.

"Ride class methods"
Ride class >> new
    "Override new to prevent direct instantiation of the abstract class"
    self == Ride ifTrue: [self error: 'Ride is an abstract class. Create a specific type of ride.'].
    ^super new

Ride class >> from: pickup to: dropoff distance: dist
    "Convenience constructor method"
    ^self new
        pickupLocation: pickup;
        dropoffLocation: dropoff;
        distance: dist;
        yourself

"Ride instance methods"
Ride >> initialize
    "Initialize a new ride instance"
    super initialize.
    rideID := UUID new asString.
    baseFare := 2.0.
    status := 'requested'.
    requestTime := DateAndTime now.

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
    "Validate that distance is positive"
    aDistance > 0 
        ifTrue: [distance := aDistance]
        ifFalse: [self error: 'Distance must be positive'].

Ride >> distance
    ^distance.

Ride >> status: aStatus
    status := aStatus.
    aStatus = 'completed' ifTrue: [completionTime := DateAndTime now].

Ride >> status
    ^status.

Ride >> requestTime
    ^requestTime.
    
Ride >> completionTime
    ^completionTime.
    
Ride >> driver: aDriver
    driver := aDriver.
    
Ride >> driver
    ^driver.

Ride >> isCompleted
    ^status = 'completed'.

Ride >> inProgress
    self status: 'in-progress'.
    
Ride >> complete
    self status: 'completed'.

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
      ', Fare: $', self fare asString,
      ', Status: ', status.

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
    ^baseFare + (ratePerMile * distance).

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
    ^baseFare + luxuryFee + (ratePerMile * distance).

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
    aNumber > 0
        ifTrue: [numberOfRiders := aNumber]
        ifFalse: [self error: 'Number of riders must be positive'].

SharedRide >> numberOfRiders
    ^numberOfRiders.

SharedRide >> calculateFare
    "Shared fare calculation"
    ^(baseFare + (ratePerMile * distance)) / numberOfRiders.

SharedRide >> rideDetails
    ^super rideDetails, ' (Shared, Riders: ', numberOfRiders asString, ')'.


"Define Driver class"
Object subclass: #Driver
    instanceVariableNames: 'driverID name rating assignedRides location available'
    classVariableNames: ''
    package: 'RideSharingSystem'.

"Driver instance methods"
Driver >> initialize
    super initialize.
    driverID := UUID new asString.
    rating := 5.0.
    assignedRides := OrderedCollection new.
    available := true.

Driver >> driverID: anID
    driverID := anID.

Driver >> driverID
    ^driverID.

Driver >> name: aName
    name := aName.

Driver >> name
    ^name.

Driver >> rating: aRating
    (aRating between: 1.0 and: 5.0)
        ifTrue: [rating := aRating]
        ifFalse: [self error: 'Rating must be between 1 and 5'].

Driver >> rating
    ^rating.
    
Driver >> location: aLocation
    location := aLocation.
    
Driver >> location
    ^location.
    
Driver >> available: aBoolean
    available := aBoolean.
    
Driver >> available
    ^available.

Driver >> addRide: aRide
    assignedRides add: aRide.
    aRide driver: self.
    self available: false.
    aRide inProgress.

Driver >> completeRide: aRide
    (assignedRides includes: aRide) ifTrue: [
        aRide complete.
        self available: true.
    ].

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
      ', Total Earnings: $', self calculateTotalEarnings asString,
      ', Available: ', available asString.

"Define Rider class"
Object subclass: #Rider
    instanceVariableNames: 'riderID name requestedRides location'
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
    
Rider >> location: aLocation
    location := aLocation.
    
Rider >> location
    ^location.

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

"Define RideSystem class to manage ride matching"
Object subclass: #RideSystem
    instanceVariableNames: 'riders drivers availableRides'
    classVariableNames: ''
    package: 'RideSharingSystem'.

"RideSystem instance methods"
RideSystem >> initialize
    super initialize.
    riders := OrderedCollection new.
    drivers := OrderedCollection new.
    availableRides := OrderedCollection new.

RideSystem >> addRider: aRider
    riders add: aRider.
    
RideSystem >> addDriver: aDriver
    drivers add: aDriver.
    
RideSystem >> registerRide: aRide
    availableRides add: aRide.
    
RideSystem >> findAvailableDriversNear: aLocation
    "Simple implementation to find available drivers"
    ^drivers select: [:driver | driver available].
    
RideSystem >> assignRide: aRide toDriver: aDriver
    (availableRides includes: aRide) ifTrue: [
        aDriver addRide: aRide.
        availableRides remove: aRide.
    ].

"Example Usage"
| system alice bob dave eve ride1 ride2 ride3 |
system := RideSystem new.

alice := Rider new name: 'Alice'; location: 'Downtown'.
bob := Rider new name: 'Bob'; location: 'Uptown'.
system addRider: alice.
system addRider: bob.

dave := Driver new name: 'Dave'; rating: 4.8; location: 'Downtown'; available: true.
eve := Driver new name: 'Eve'; rating: 4.9; location: 'Midtown'; available: true.
system addDriver: dave.
system addDriver: eve.

"Using convenience constructor"
ride1 := StandardRide from: 'Downtown' to: 'Airport' distance: 10.5.
ride2 := PremiumRide from: 'Airport' to: 'Hotel' distance: 8.2.
ride3 := SharedRide from: 'Uptown' to: 'Beach' distance: 15.0.
ride3 numberOfRiders: 2.

"Request rides"
alice requestRide: ride1.
alice requestRide: ride2.
bob requestRide: ride3.

"Register rides with system"
system registerRide: ride1.
system registerRide: ride2.
system registerRide: ride3.

"Assign rides to drivers"
system assignRide: ride1 toDriver: dave.
system assignRide: ride2 toDriver: eve.

"Complete a ride"
dave completeRide: ride1.

"Output Information"
Transcript show: 'Rider Information:'; cr.
Transcript show: alice viewRides; cr; cr.
Transcript show: 'Driver Information:'; cr.
Transcript show: dave getDriverInfo; cr.
Transcript show: eve getDriverInfo; cr; cr.

"Demonstrate polymorphism"
Transcript show: 'Polymorphic Fare Calculation:'; cr.
{ride1. ride2. ride3} do: [:each |
    Transcript show: each rideDetails; cr.
].
