# Utility Bill Logger 📊

A modern, progressive web application for tracking daily utility consumption. Built with Laravel and Tailwind CSS, this application helps users monitor their utility usage patterns and manage billing cycles effectively.

![Utility Bill Logger](https://img.shields.io/badge/Laravel-12.x-red?style=flat-square&logo=laravel)
![PHP](https://img.shields.io/badge/PHP-8.2+-blue?style=flat-square&logo=php)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4.0-38B2AC?style=flat-square&logo=tailwind-css)
![PWA](https://img.shields.io/badge/PWA-Ready-green?style=flat-square&logo=pwa)

## ✨ Features

### 🔐 User Authentication
- Secure user registration and login system
- User-specific data isolation
- Session management

### 📅 Billing Cycle Management
- Create and manage multiple billing cycles
- Set start and end dates for billing periods
- Track cycle status (active/inactive)
- Automatic consumption calculation

### 📊 Daily Reading Tracking
- Log daily utility readings with timestamps
- Support for decimal precision (up to 2 decimal places)
- Duplicate reading prevention
- Reading validation (must be greater than previous readings)
- Optional notes for each reading

### 🚀 Progressive Web App (PWA)
- **Installable**: Add to home screen on mobile devices
- **Responsive Design**: Optimized for all screen sizes
- **Fast Loading**: Optimized performance and caching

### 📱 Mobile-First Design
- Responsive UI built with Tailwind CSS
- Touch-friendly interface
- Quick add functionality for daily readings
- Intuitive navigation

### 🔍 Data Validation
- Smart reading validation to prevent data inconsistencies
- Duplicate time detection for same-day readings
- Logical reading progression enforcement
- User-friendly error messages with suggestions

## 🛠️ Technology Stack

- **Backend**: Laravel 12.x (PHP 8.2+)
- **Frontend**: Blade templates with Tailwind CSS 4.0
- **Database**: SQLite (default), supports MySQL/PostgreSQL
- **Build Tool**: Vite
- **PWA**: Service Workers with Workbox
- **Testing**: Pest PHP

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- **PHP** 8.2 or higher
- **Composer** (PHP package manager)
- **Node.js** 18+ and **npm**
- **Git**

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/utility-bill-logger.git
cd utility-bill-logger
```

### 2. Install PHP Dependencies
```bash
composer install
```

### 3. Install Node.js Dependencies
```bash
npm install
```

### 4. Environment Setup
```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate
```

### 5. Database Setup
```bash
# Create SQLite database (default)
touch database/database.sqlite

# Run migrations
php artisan migrate

# (Optional) Seed with sample data
php artisan db:seed
```

### 6. Build Assets
```bash
# Development
npm run dev

# Production
npm run build
```

### 7. Start the Development Server
```bash
# Using Laravel's built-in server
php artisan serve

# Or use the combined dev script
composer run dev
```

The application will be available at `http://localhost:8000`

## 📖 Usage

### Getting Started

1. **Register/Login**: Create an account or log in to access your dashboard
2. **Create Billing Cycle**: Set up your first billing cycle with start date and initial reading
3. **Add Daily Readings**: Start logging your daily utility consumption
4. **Monitor Progress**: View your consumption patterns and billing cycle status

### Key Features

#### Billing Cycles
- **Create**: Set up new billing periods with start dates and initial readings
- **Manage**: Edit cycle details and mark cycles as active/inactive
- **View**: See consumption totals and cycle progress

#### Daily Readings
- **Quick Add**: Fast entry for today's reading
- **Detailed Entry**: Full form with date, time, value, and notes
- **Validation**: Smart validation prevents data inconsistencies
- **History**: View all readings with filtering and sorting

#### PWA Features
- **Install**: Add to home screen for app-like experience
- **Responsive**: Optimized for mobile and desktop devices
- **Fast**: Quick loading and smooth interactions

## 🗄️ Database Schema

### Users Table
- `id` - Primary key
- `name` - User's full name
- `email` - Unique email address
- `password` - Hashed password
- `created_at`, `updated_at` - Timestamps

### Billing Cycles Table
- `id` - Primary key
- `user_id` - Foreign key to users
- `name` - Cycle name/description
- `start_date` - Cycle start date
- `start_reading` - Initial meter reading
- `end_date` - Cycle end date (optional)
- `end_reading` - Final meter reading (optional)
- `is_active` - Active status boolean

### Daily Readings Table
- `id` - Primary key
- `user_id` - Foreign key to users
- `billing_cycle_id` - Foreign key to billing cycles
- `reading_date` - Date of reading
- `reading_time` - Time of reading
- `reading_value` - Meter reading value
- `notes` - Optional notes
- `created_at`, `updated_at` - Timestamps

## 🧪 Testing

Run the test suite using Pest:

```bash
# Run all tests
composer test

# Run tests with coverage
composer test -- --coverage
```

## 🚀 Deployment

### Production Setup

1. **Environment Configuration**
   ```bash
   # Set production environment
   APP_ENV=production
   APP_DEBUG=false
   
   # Configure database
   DB_CONNECTION=mysql
   DB_HOST=your-db-host
   DB_DATABASE=your-db-name
   DB_USERNAME=your-db-user
   DB_PASSWORD=your-db-password
   ```

2. **Optimize for Production**
   ```bash
   # Cache configuration
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   
   # Build assets
   npm run build
   ```

3. **Web Server Configuration**
   - Point web server to `public/` directory
   - Ensure proper permissions on `storage/` and `bootstrap/cache/`
   - Configure SSL for HTTPS

### Docker Deployment

```bash
# Build and run with Docker
docker build -t utility-bill-logger .
docker run -p 8000:8000 utility-bill-logger
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

### 1. Fork the Repository
Fork the project on GitHub and clone your fork locally.

### 2. Create a Feature Branch
```bash
git checkout -b feature/amazing-feature
```

### 3. Make Your Changes
- Follow Laravel coding standards
- Write tests for new features
- Update documentation as needed

### 4. Test Your Changes
```bash
composer test
npm run build
```

### 5. Submit a Pull Request
- Provide a clear description of changes
- Include screenshots for UI changes
- Reference any related issues

### Development Guidelines

- **Code Style**: Follow PSR-12 and Laravel conventions
- **Testing**: Write tests for new features and bug fixes
- **Documentation**: Update README and inline documentation
- **Commits**: Use conventional commit messages

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Laravel](https://laravel.com/) - The PHP framework for web artisans
- [Tailwind CSS](https://tailwindcss.com/) - A utility-first CSS framework
- [Pest](https://pestphp.com/) - An elegant PHP testing framework
- [Vite](https://vitejs.dev/) - Next generation frontend tooling

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/utility-bill-logger/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/utility-bill-logger/discussions)
- **Email**: your-email@example.com

## 🗺️ Roadmap

- [ ] **Data Export**: Export readings to CSV/PDF
- [ ] **Charts & Analytics**: Visual consumption graphs
- [ ] **Multi-utility Support**: Track different utility types
- [ ] **Notifications**: Billing cycle reminders
- [ ] **API**: RESTful API for mobile apps
- [ ] **Multi-language**: Internationalization support
- [ ] **Dark Mode**: Theme switching capability
- [ ] **Data Backup**: Cloud backup integration
- [ ] **Offline Support**: Work without internet connection

---

**Made with ❤️ by the Utility Bill Logger Team**

If you find this project helpful, please consider giving it a ⭐ on GitHub!
