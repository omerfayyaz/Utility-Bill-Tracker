<x-app-layout>
    <div class="max-w-md mx-auto">
        <!-- Header -->
        <div class="text-center mb-8">
            <h2 class="text-2xl font-bold text-gray-900">Edit Billing Cycle</h2>
            <p class="mt-2 text-sm text-gray-600">
                Update cycle: {{ $billingCycle->name }}
            </p>
        </div>

        <!-- Form -->
        <div class="bg-white shadow rounded-lg p-6">
            <form action="{{ route('billing-cycles.update', $billingCycle) }}" method="POST">
                @csrf
                @method('PUT')

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
                                   value="{{ old('name', $billingCycle->name) }}"
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
                                   value="{{ old('start_date', $billingCycle->start_date->format('Y-m-d')) }}"
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
                                   value="{{ old('start_reading', $billingCycle->start_reading) }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-lg"
                                   placeholder="Enter starting meter reading"
                                   required>
                        </div>
                        @error('start_reading')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- End Date -->
                    <div>
                        <label for="end_date" class="block text-sm font-medium text-gray-700">
                            End Date (optional)
                        </label>
                        <div class="mt-1">
                            <input type="date"
                                   name="end_date"
                                   id="end_date"
                                   value="{{ old('end_date', $billingCycle->end_date ? $billingCycle->end_date->format('Y-m-d') : '') }}"
                                   min="{{ $billingCycle->start_date->format('Y-m-d') }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        </div>
                        @error('end_date')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                        <p class="mt-1 text-sm text-gray-500">
                            Leave empty if cycle is still ongoing
                        </p>
                    </div>

                    <!-- End Reading -->
                    <div>
                        <label for="end_reading" class="block text-sm font-medium text-gray-700">
                            End Reading (units, optional)
                        </label>
                        <div class="mt-1">
                            <input type="number"
                                   name="end_reading"
                                   id="end_reading"
                                   step="0.01"
                                   min="0"
                                   value="{{ old('end_reading', $billingCycle->end_reading) }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-lg"
                                   placeholder="Enter ending meter reading">
                        </div>
                        @error('end_reading')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                        <p class="mt-1 text-sm text-gray-500">
                            Set when the cycle ends
                        </p>
                    </div>

                    <!-- Submit Button -->
                    <div class="flex space-x-3">
                        <a href="{{ route('billing-cycles.show', $billingCycle) }}"
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

        <!-- Current Stats -->
        <div class="mt-6 bg-gray-50 rounded-lg p-4">
            <h3 class="text-sm font-medium text-gray-900 mb-3">Current Statistics</h3>
            <div class="space-y-2 text-sm text-gray-600">
                <div class="flex justify-between">
                    <span>Total Consumed:</span>
                    <span class="font-medium">{{ number_format($billingCycle->total_consumed_units, 2) }} units</span>
                </div>
                <div class="flex justify-between">
                    <span>Days Elapsed:</span>
                    <span class="font-medium">{{ $billingCycle->days_elapsed }} days</span>
                </div>
                <div class="flex justify-between">
                    <span>Status:</span>
                    <span class="font-medium {{ $billingCycle->is_active ? 'text-green-600' : 'text-gray-600' }}">
                        {{ $billingCycle->is_active ? 'Active' : 'Inactive' }}
                    </span>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
