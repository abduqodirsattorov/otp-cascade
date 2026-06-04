<?php

namespace OtpCascade\Laravel\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;

class PushOtpController extends Controller
{
    /**
     * Store FCM Push Token for a user device
     */
    public function storeToken(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'push_token' => 'required|string',
            'device_type' => 'nullable|string',
            'device_name' => 'nullable|string',
        ]);

        DB::table('user_push_tokens')->updateOrInsert(
            [
                'user_id' => $request->input('user_id'),
                'push_token' => $request->input('push_token')
            ],
            [
                'device_type' => $request->input('device_type'),
                'device_name' => $request->input('device_name'),
                'updated_at' => now(),
                'created_at' => now(),
            ]
        );

        return response()->json(['success' => true, 'message' => 'Push token stored successfully']);
    }

    /**
     * Generate and Send OTP via FCM High-Priority Push
     */
    public function sendOtp(Request $request)
    {
        $request->validate([
            'user_id' => 'required'
        ]);

        $userId = $request->input('user_id');

        // Fetch user's registered devices
        $devices = DB::table('user_push_tokens')
            ->where('user_id', $userId)
            ->get();

        if ($devices->isEmpty()) {
            return response()->json([
                'success' => false,
                'fallback' => true,
                'message' => 'No active device tokens found. Fallback to SMS.'
            ]);
        }

        // Generate 6-digit OTP
        $otp = random_int(100000, 999999);
        $otpHash = hash('sha256', $otp);

        // Save hashed OTP and attempt count in cache (3 minutes TTL)
        $otpCacheKey = config('otp_cascade.cache.prefix') . "push_otp:{$userId}";
        Cache::put($otpCacheKey, [
            'hash' => $otpHash,
            'attempts' => 0,
        ], config('otp_cascade.cache.otp_ttl'));

        // Send FCM High Priority Push Notification to all active devices
        $successCount = 0;
        foreach ($devices as $device) {
            $response = $this->sendFcmNotification($device->push_token, $otp);
            if ($response) {
                $successCount++;
            }
        }

        if ($successCount === 0) {
            return response()->json([
                'success' => false,
                'fallback' => true,
                'message' => 'Failed to deliver push notification. Fallback to SMS.'
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'In-app push notification sent successfully.'
        ]);
    }

    /**
     * Verify In-App Push OTP
     */
    public function verifyOtp(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'otp' => 'required|digits:6'
        ]);

        $userId = $request->input('user_id');
        $otpInput = $request->input('otp');

        $otpCacheKey = config('otp_cascade.cache.prefix') . "push_otp:{$userId}";
        $cachedData = Cache::get($otpCacheKey);

        if (!$cachedData) {
            return response()->json([
                'error' => 'OTP has expired or was not generated',
                'fallback' => true
            ], 400);
        }

        // Increment attempts
        $cachedData['attempts']++;
        Cache::put($otpCacheKey, $cachedData, config('otp_cascade.cache.otp_ttl'));

        if ($cachedData['attempts'] > config('otp_cascade.security.max_attempts', 3)) {
            Cache::forget($otpCacheKey);
            return response()->json([
                'error' => 'Too many invalid attempts. Suspended.',
                'fallback' => true
            ], 429);
        }

        // Check if hash matches
        $inputHash = hash('sha256', $otpInput);
        if (hash_equals($cachedData['hash'], $inputHash)) {
            Cache::forget($otpCacheKey);
            return response()->json([
                'success' => true,
                'message' => 'OTP verified successfully'
            ]);
        }

        return response()->json([
            'error' => 'Invalid OTP code',
            'attempts_left' => config('otp_cascade.security.max_attempts', 3) - $cachedData['attempts']
        ], 400);
    }

    /**
     * Send FCM Push Message
     */
    private function sendFcmNotification($token, $otp)
    {
        $credentialsFile = config('otp_cascade.fcm.credentials_file');
        
        // Setup FCM V1 API Request
        // If credentials file is not set or missing, fall back to Laravel log file in local development
        if (!file_exists($credentialsFile)) {
            \Log::info("FCM credentials missing. Mock Push to token [{$token}] with OTP: {$otp}");
            return true;
        }

        // Real Firebase V1 API request
        try {
            // Load Google client for FCM V1 OAuth2 token
            $client = new \Google\Client();
            $client->setAuthConfig($credentialsFile);
            $client->addScope('https://www.googleapis.com/auth/firebase.messaging');
            $client->fetchAccessTokenWithAssertion();
            $accessToken = $client->getAccessToken()['access_token'];

            $projectId = config('otp_cascade.fcm.project_id');
            $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

            $response = Http::withToken($accessToken)->post($url, [
                'message' => [
                    'token' => $token,
                    'notification' => [
                        'title' => 'Tasdiqlash kodi',
                        'body' => 'Ilovaga kirishni tasdiqlang'
                    ],
                    'data' => [
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                        'type' => 'OTP_APPROVAL',
                        'otp' => (string)$otp
                    ],
                    'android' => [
                        'priority' => 'high'
                    ],
                    'apns' => [
                        'headers' => [
                            'apns-priority' => '10'
                        ]
                    ]
                ]
            ]);

            return $response->successful();
        } catch (\Exception $e) {
            \Log::error("FCM Error: " . $e->getMessage());
            return false;
        }
    }
}
