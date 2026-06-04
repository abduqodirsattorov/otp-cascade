<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Relying Party (RP) Settings for WebAuthn / Passkeys
    |--------------------------------------------------------------------------
    |
    | The Relying Party (RP) represents the application registering/authenticating
    | the passkey. The 'id' must be the domain name of your application
    | (e.g., 'example.com').
    |
    */
    'rp' => [
        'name' => env('OTP_CASCADE_RP_NAME', env('APP_NAME', 'Laravel Application')),
        'id' => env('OTP_CASCADE_RP_ID', parse_url(env('APP_URL', 'http://localhost'), PHP_URL_HOST)),
        'icon' => env('OTP_CASCADE_RP_ICON', null),
    ],

    /*
    |--------------------------------------------------------------------------
    | Redis and Cache Settings
    |--------------------------------------------------------------------------
    |
    | Used for temporary storage of WebAuthn challenges and Push OTP codes.
    |
    */
    'cache' => [
        'prefix' => 'otp_cascade:',
        'challenge_ttl' => 60, // in seconds
        'otp_ttl' => 180, // in seconds (3 minutes)
    ],

    /*
    |--------------------------------------------------------------------------
    | Push Notification (FCM) Settings
    |--------------------------------------------------------------------------
    |
    | Configuration for sending high-priority In-App Push OTPs to devices.
    |
    */
    'fcm' => [
        'project_id' => env('FCM_PROJECT_ID'),
        'credentials_file' => env('FCM_CREDENTIALS_FILE', storage_path('app/fcm-credentials.json')),
    ],

    /*
    |--------------------------------------------------------------------------
    | Cascade Flow Ordering and Limits
    |--------------------------------------------------------------------------
    |
    | Max attempts before locking, and configuration of backup gateway.
    |
    */
    'security' => [
        'max_attempts' => 3,
        'cooldown_time' => 60, // in seconds
    ],

    /*
    |--------------------------------------------------------------------------
    | Backup SMS Gateway Config
    |--------------------------------------------------------------------------
    */
    'sms' => [
        'default' => env('OTP_CASCADE_SMS_PROVIDER', 'log'),
        'providers' => [
            'log' => [
                'driver' => 'log',
            ],
            // Add custom gateways here (e.g., PlayMobile, Eskiz)
        ]
    ]
];
