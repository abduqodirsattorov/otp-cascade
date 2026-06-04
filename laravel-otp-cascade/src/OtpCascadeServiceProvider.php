<?php

namespace OtpCascade\Laravel;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Route;

class OtpCascadeServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->mergeConfigFrom(
            __DIR__ . '/../config/otp_cascade.php', 'otp_cascade'
        );
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Publish configuration file
        if ($this->app->runningInConsole()) {
            $this->publishes([
                __DIR__ . '/../config/otp_cascade.php' => config_path('otp_cascade.php'),
            ], 'otp-cascade-config');

            // Load database migrations
            $this->loadMigrationsFrom(__DIR__ . '/../database/migrations');
        }

        // Register package routes
        $this->registerRoutes();
    }

    /**
     * Register package routes.
     */
    protected function registerRoutes(): void
    {
        Route::group([
            'prefix' => 'api/otp',
            'middleware' => ['api'],
            'namespace' => 'OtpCascade\Laravel\Http\Controllers',
        ], function () {
            $this->loadRoutesFrom(__DIR__ . '/../routes/api.php');
        });
    }
}
