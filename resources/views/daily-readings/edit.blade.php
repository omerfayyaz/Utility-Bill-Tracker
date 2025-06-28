<x-app-layout>
    <div class="max-w-md mx-auto">
        <!-- Header -->
        <div class="text-center mb-8">
            <h2 class="text-2xl font-bold text-gray-900">Edit Daily Reading</h2>
            <p class="mt-2 text-sm text-gray-600">
                Update reading details
            </p>
        </div>

        <!-- Reading Info -->
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <svg class="h-5 w-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                </div>
                <div class="ml-3">
                    <h3 class="text-sm font-medium text-blue-800">
                        Current Reading Details
                    </h3>
                    <div class="mt-1 text-sm text-blue-700">
                        <p>Date: {{ $dailyReading->reading_date->format('M d, Y') }}</p>
                        <p>Time: {{ $dailyReading->reading_time }}</p>
                        <p>Value: {{ number_format($dailyReading->reading_value, 2) }} units</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Error Messages -->
        @if($errors->any())
            <div class="mb-6 bg-red-50 border border-red-200 rounded-lg p-4">
                <div class="flex">
                    <div class="flex-shrink-0">
                        <svg class="h-5 w-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                        </svg>
                    </div>
                    <div class="ml-3">
                        <h3 class="text-sm font-medium text-red-800">
                            @if($errors->has('reading_time'))
                                Duplicate Reading Detected
                            @elseif($errors->has('reading_value'))
                                Invalid Reading Value
                            @else
                                Validation Error
                            @endif
                        </h3>
                        <div class="mt-2 text-sm text-red-700">
                            @foreach($errors->all() as $error)
                                <p>{{ $error }}</p>
                            @endforeach
                            @if($errors->has('reading_time'))
                                <div class="mt-2">
                                    <p class="font-medium">Suggestions:</p>
                                    <ul class="list-disc list-inside mt-1 space-y-1">
                                        <li>Choose a different time for this date</li>
                                        <li>Select a different date</li>
                                        <li>Check existing readings for this date</li>
                                    </ul>
                                </div>
                            @elseif($errors->has('reading_value'))
                                <div class="mt-2">
                                    <p class="font-medium">Reading Value Rules:</p>
                                    <ul class="list-disc list-inside mt-1 space-y-1">
                                        <li>Must be greater than the previous reading</li>
                                        <li>Must be less than the next reading</li>
                                        <li>Must be greater than or equal to cycle start reading</li>
                                    </ul>
                                </div>
                            @endif
                        </div>
                    </div>
                </div>
            </div>
        @endif

        <!-- Form -->
        <div class="bg-white shadow rounded-lg p-6">
            <form action="{{ route('daily-readings.update', $dailyReading) }}" method="POST">
                @csrf
                @method('PUT')

                <div class="space-y-6">
                    <!-- Reading Date -->
                    <div>
                        <label for="reading_date" class="block text-sm font-medium text-gray-700">
                            Reading Date
                        </label>
                        <div class="mt-1">
                            <input type="date"
                                   name="reading_date"
                                   id="reading_date"
                                   value="{{ old('reading_date', $dailyReading->reading_date->format('Y-m-d')) }}"
                                   max="{{ now()->format('Y-m-d') }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('reading_date') border-red-300 focus:ring-red-500 focus:border-red-500 @enderror"
                                   required>
                        </div>
                        @error('reading_date')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Reading Time -->
                    <div>
                        <label for="reading_time" class="block text-sm font-medium text-gray-700">
                            Reading Time
                        </label>
                        <div class="mt-1">
                            <input type="time"
                                   name="reading_time"
                                   id="reading_time"
                                   value="{{ old('reading_time', $dailyReading->reading_time->format('H:i')) }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('reading_time') border-red-300 focus:ring-red-500 focus:border-red-500 @enderror"
                                   required>
                        </div>
                        @error('reading_time')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Reading Value -->
                    <div>
                        <label for="reading_value" class="block text-sm font-medium text-gray-700">
                            Reading Value (units)
                        </label>
                        <div class="mt-1 relative rounded-md shadow-sm">
                            <input type="number"
                                   name="reading_value"
                                   id="reading_value"
                                   step="0.01"
                                   min="0"
                                   value="{{ old('reading_value', $dailyReading->reading_value) }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-lg @error('reading_value') border-red-300 focus:ring-red-500 focus:border-red-500 @enderror"
                                   placeholder="Enter reading value"
                                   required>
                        </div>
                        @error('reading_value')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Notes -->
                    <div>
                        <label for="notes" class="block text-sm font-medium text-gray-700">
                            Notes (optional)
                        </label>
                        <div class="mt-1">
                            <textarea name="notes"
                                      id="notes"
                                      rows="3"
                                      class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('notes') border-red-300 focus:ring-red-500 focus:border-red-500 @enderror"
                                      placeholder="Any additional notes about this reading...">{{ old('notes', $dailyReading->notes) }}</textarea>
                        </div>
                        @error('notes')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Submit Button -->
                    <div class="flex space-x-3">
                        <a href="{{ route('daily-readings.index') }}"
                           class="flex-1 inline-flex justify-center items-center px-4 py-3 border border-gray-300 rounded-lg font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition ease-in-out duration-150">
                            Cancel
                        </a>
                        <button type="submit"
                                class="flex-1 inline-flex justify-center items-center px-4 py-3 border border-transparent rounded-lg font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition ease-in-out duration-150">
                            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                            Update
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</x-app-layout>
