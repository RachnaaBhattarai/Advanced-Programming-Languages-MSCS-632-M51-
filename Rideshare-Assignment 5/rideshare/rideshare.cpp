#include <iostream>
#include <vector>
using namespace std;

class Ride {
protected:
    int rideID;
    string pickupLocation, dropoffLocation;
    double distance;

public:
    Ride(int id, string pickup, string dropoff, double dist)
        : rideID(id), pickupLocation(pickup), dropoffLocation(dropoff), distance(dist) {}

    virtual double fare() = 0; // Pure virtual function

    virtual void rideDetails() {
        cout << "Ride ID: " << rideID
             << ", From: " << pickupLocation
             << " to " << dropoffLocation
             << ", Distance: " << distance << " miles, Fare: $" << fare() << endl;
    }
    
    virtual ~Ride() {} // Virtual destructor
};

class StandardRide : public Ride {
public:
    StandardRide(int id, string pickup, string dropoff, double dist)
        : Ride(id, pickup, dropoff, dist) {}

    double fare() override {
        return distance * 2.0; // $2 per mile
    }
};

class PremiumRide : public Ride {
public:
    PremiumRide(int id, string pickup, string dropoff, double dist)
        : Ride(id, pickup, dropoff, dist) {}

    double fare() override {
        return distance * 3.5; // $3.5 per mile
    }
};

class Driver {
private:
    int driverID;
    string name;
    double rating;
    vector<Ride*> assignedRides;

public:
    Driver(int id, string n, double r) : driverID(id), name(n), rating(r) {}

    void addRide(Ride* ride) {
        assignedRides.push_back(ride);
    }

    void getDriverInfo() {
        cout << "Driver ID: " << driverID << ", Name: " << name << ", Rating: " << rating << endl;
        cout << "Completed Rides: " << assignedRides.size() << endl;
    }
};

class Rider {
private:
    int riderID;
    string name;
    vector<Ride*> requestedRides;

public:
    Rider(int id, string n) : riderID(id), name(n) {}

    void requestRide(Ride* ride) {
        requestedRides.push_back(ride);
    }

    void viewRides() {
        cout << "Rider: " << name << ", Ride History:" << endl;
        for (auto ride : requestedRides) {
            ride->rideDetails();
        }
    }
};

// ** Main Function **
int main() {
    Rider rider(1, "Alice");
    Driver driver(101, "John", 4.8);

    Ride* ride1 = new StandardRide(1001, "Downtown", "Uptown", 10);
    Ride* ride2 = new PremiumRide(1002, "Airport", "Hotel", 15);

    rider.requestRide(ride1);
    rider.requestRide(ride2);

    driver.addRide(ride1);
    driver.addRide(ride2);

    rider.viewRides();
    driver.getDriverInfo();

    delete ride1;
    delete ride2;

    return 0;
}
