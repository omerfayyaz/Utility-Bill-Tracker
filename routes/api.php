use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DailyReadingController;

Route::post('/daily-readings/offline-sync', [DailyReadingController::class, 'offlineSync']);
