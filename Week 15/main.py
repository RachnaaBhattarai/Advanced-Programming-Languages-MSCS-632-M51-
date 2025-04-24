class StatisticsCalculator:
    def __init__(self, data=None):
        """Initialize the calculator with optional data."""
        self.data = data if data is not None else []
    
    def set_data(self, data):
        """Set or update the data."""
        self.data = data
    
    def get_data(self):
        """Return the current data."""
        return self.data
    
    def calculate_mean(self):
        """Calculate the mean of the data."""
        if not self.data:
            return 0
        return sum(self.data) / len(self.data)
    
    def calculate_median(self):
        """Calculate the median of the data."""
        if not self.data:
            return 0
        
        # Create a sorted copy of the data
        sorted_data = sorted(self.data)
        n = len(sorted_data)
        
        # Check if the number of elements is even or odd
        if n % 2 == 0:
            # Even number of elements
            return (sorted_data[n//2 - 1] + sorted_data[n//2]) / 2
        else:
            # Odd number of elements
            return sorted_data[n//2]
    
    def calculate_mode(self):
        """Calculate the mode(s) of the data."""
        if not self.data:
            return []
        
        # Count the frequency of each value
        frequency = {}
        for value in self.data:
            if value in frequency:
                frequency[value] += 1
            else:
                frequency[value] = 1
        
        # Find the maximum frequency
        max_freq = max(frequency.values())
        
        # If all values appear only once, there is no mode
        if max_freq == 1:
            return []
        
        # Return all values with the maximum frequency
        modes = [value for value, freq in frequency.items() if freq == max_freq]
        return modes
    
    def display_statistics(self):
        """Display all statistics."""
        mean = self.calculate_mean()
        median = self.calculate_median()
        modes = self.calculate_mode()
        
        print(f"Input data: {self.data}")
        print(f"Mean: {mean:.2f}")
        print(f"Median: {median:.2f}")
        
        if not modes:
            print("Mode: No mode (all values appear equally often)")
        else:
            print(f"Mode: {modes}")


def main():
    # Create an instance of the StatisticsCalculator
    calculator = StatisticsCalculator()
    
    try:
        # Get input from the user
        input_str = input("Python => Enter integers separated by spaces: ")
        numbers = [int(x) for x in input_str.split()]
        
        # Set the data and display statistics
        calculator.set_data(numbers)
        calculator.display_statistics()
        
    except ValueError:
        print("Error: Please enter valid integers separated by spaces.")


if __name__ == "__main__":
    main()