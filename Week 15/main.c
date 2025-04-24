#include <stdio.h>
#include <stdlib.h>

// Function prototypes
double calculate_mean(int arr[], int size);
double calculate_median(int arr[], int size);
void calculate_mode(int arr[], int size, int** mode_values, int* mode_count);
void sort_array(int arr[], int size);
void print_array(int arr[], int size);

int main() {
    int size;
    printf("Enter the number of integers: ");
    scanf("%d", &size);
    
    if (size <= 0) {
        printf("Invalid size. Please enter a positive number.\n");
        return 1;
    }
    
    // Dynamically allocate memory for the array
    int* numbers = (int*)malloc(size * sizeof(int));
    if (numbers == NULL) {
        printf("Memory allocation failed.\n");
        return 1;
    }
    
    // Input the integers
    printf("Enter %d integers:\n", size);
    for (int i = 0; i < size; i++) {
        scanf("%d", &numbers[i]);
    }
    
    // Calculate and display statistics
    printf("\nInput array: ");
    print_array(numbers, size);
    
    double mean = calculate_mean(numbers, size);
    printf("Mean: %.2f\n", mean);
    
    double median = calculate_median(numbers, size);
    printf("Median: %.2f\n", median);
    
    int* mode_values = NULL;
    int mode_count = 0;
    calculate_mode(numbers, size, &mode_values, &mode_count);
    
    printf("Mode: ");
    if (mode_count == 0) {
        printf("No mode (all values appear equally often)\n");
    } else {
        print_array(mode_values, mode_count);
    }
    
    // Free dynamically allocated memory
    free(numbers);
    free(mode_values);
    
    return 0;
}

// Calculate the mean of the array
double calculate_mean(int arr[], int size) {
    if (size == 0) return 0;
    
    int sum = 0;
    for (int i = 0; i < size; i++) {
        sum += arr[i];
    }
    
    return (double)sum / size;
}

// Calculate the median of the array
double calculate_median(int arr[], int size) {
    if (size == 0) return 0;
    
    // Create a copy of the array to sort
    int* temp = (int*)malloc(size * sizeof(int));
    if (temp == NULL) {
        printf("Memory allocation failed in median calculation.\n");
        return 0;
    }
    
    for (int i = 0; i < size; i++) {
        temp[i] = arr[i];
    }
    
    // Sort the array
    sort_array(temp, size);
    
    double median;
    if (size % 2 == 0) {
        // Even number of elements
        median = (temp[size/2 - 1] + temp[size/2]) / 2.0;
    } else {
        // Odd number of elements
        median = temp[size/2];
    }
    
    free(temp);
    return median;
}

// Calculate the mode of the array
void calculate_mode(int arr[], int size, int** mode_values, int* mode_count) {
    if (size == 0) {
        *mode_count = 0;
        return;
    }
    
    // Create a copy and sort it
    int* sorted = (int*)malloc(size * sizeof(int));
    if (sorted == NULL) {
        printf("Memory allocation failed in mode calculation.\n");
        *mode_count = 0;
        return;
    }
    
    for (int i = 0; i < size; i++) {
        sorted[i] = arr[i];
    }
    
    sort_array(sorted, size);
    
    // Find the frequency of each value
    int max_freq = 0;
    int current_freq = 1;
    int current_value = sorted[0];
    
    // First pass: find the maximum frequency
    for (int i = 1; i < size; i++) {
        if (sorted[i] == current_value) {
            current_freq++;
        } else {
            if (current_freq > max_freq) {
                max_freq = current_freq;
            }
            current_value = sorted[i];
            current_freq = 1;
        }
    }
    
    // Check the last group
    if (current_freq > max_freq) {
        max_freq = current_freq;
    }
    
    // If all values appear only once, there is no mode
    if (max_freq == 1) {
        *mode_count = 0;
        free(sorted);
        return;
    }
    
    // Second pass: collect all values with the maximum frequency
    int* modes = (int*)malloc(size * sizeof(int));
    if (modes == NULL) {
        printf("Memory allocation failed in mode calculation.\n");
        *mode_count = 0;
        free(sorted);
        return;
    }
    
    int mode_idx = 0;
    current_freq = 1;
    current_value = sorted[0];
    
    for (int i = 1; i < size; i++) {
        if (sorted[i] == current_value) {
            current_freq++;
        } else {
            if (current_freq == max_freq) {
                modes[mode_idx++] = current_value;
            }
            current_value = sorted[i];
            current_freq = 1;
        }
    }
    
    // Check the last group
    if (current_freq == max_freq) {
        modes[mode_idx++] = current_value;
    }
    
    // Resize the modes array to the actual number of modes
    *mode_values = (int*)realloc(modes, mode_idx * sizeof(int));
    *mode_count = mode_idx;
    
    free(sorted);
}

// Bubble sort implementation
void sort_array(int arr[], int size) {
    for (int i = 0; i < size - 1; i++) {
        for (int j = 0; j < size - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                // Swap
                int temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

// Print the array
void print_array(int arr[], int size) {
    printf("[");
    for (int i = 0; i < size; i++) {
        printf("%d", arr[i]);
        if (i < size - 1) {
            printf(", ");
        }
    }
    printf("]\n");
}