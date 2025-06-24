<x-app-layout>
    <div class="max-w-md mx-auto">
        <!-- Header -->
        <div class="text-center mb-8">
            <h2 class="text-2xl font-bold text-gray-900">Create New Billing Cycle</h2>
            <p class="mt-2 text-sm text-gray-600">
                Set up a new billing cycle for your utility tracking
            </p>
        </div>

        <!-- Form -->
        <div class="bg-white shadow rounded-lg p-6">
            <form action="{{ route('billing-cycles.store') }}" method="POST">
                @csrf

                <div class="space-y-6">
                    <!-- Cycle Name -->
                    <div>
                        <label for="name" class="block text-sm font-medium text-gray-700">
                            Cycle Name
                        </label>
                        <div class="mt-1">
                            <input type="text"
                                   name="name"
                                   id="name"
                                   value="{{ old('name') }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   placeholder="e.g., January 2024, Q1 2024"
                                   required>
                        </div>
                        @error('name')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Start Date -->
                    <div>
                        <label for="start_date" class="block text-sm font-medium text-gray-700">
                            Start Date
                        </label>
                        <div class="mt-1">
                            <input type="date"
                                   name="start_date"
                                   id="start_date"
                                   value="{{ old('start_date', now()->format('Y-m-d')) }}"
                                   max="{{ now()->format('Y-m-d') }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   required>
                        </div>
                        @error('start_date')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Start Reading -->
                    <div>
                        <label for="start_reading" class="block text-sm font-medium text-gray-700">
                            Start Reading (units)
                        </label>
                        <div class="mt-1">
                            <input type="number"
                                   name="start_reading"
                                   id="start_reading"
                                   step="0.01"
                                   min="0"
                                   value="{{ old('start_reading') }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-lg"
                                   placeholder="Enter starting meter reading"
                                   required>
                        </div>
                        @error('start_reading')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                        <p class="mt-1 text-sm text-gray-500">
                            This will be the initial meter reading for this billing cycle
                        </p>
                    </div>

                    <!-- Submit Button -->
                    <div class="flex space-x-3">
                        <a href="{{ route('billing-cycles.index') }}"
                           class="flex-1 inline-flex justify-center items-center px-4 py-3 border border-gray-300 rounded-lg font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition ease-in-out duration-150">
                            Cancel
                        </a>
                        <button type="submit"
                                class="flex-1 inline-flex justify-center items-center px-4 py-3 border border-transparent rounded-lg font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition ease-in-out duration-150">
                            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                            Create Cycle
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Info Box -->
        <div class="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div class="flex">
                <div class="flex-shrink-0">
                    <svg class="h-5 w-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                </div>
                <div class="ml-3">
                    <h3 class="text-sm font-medium text-blue-800">
                        About Billing Cycles
                    </h3>
                    <div class="mt-2 text-sm text-blue-700">
                        <ul class="list-disc list-inside space-y-1">
                            <li>Only one cycle can be active at a time</li>
                            <li>Creating a new cycle will deactivate the current one</li>
                            <li>You can add daily readings to track consumption</li>
                            <li>End date and reading can be set later when the cycle ends</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
