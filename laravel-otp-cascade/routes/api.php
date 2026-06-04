<?php

use Illuminate\Support\Facades\Route;

Route::post('/passkey/register/begin', 'PasskeyController@registerBegin');
Route::post('/passkey/register/finish', 'PasskeyController@registerFinish');
Route::post('/passkey/authenticate/begin', 'PasskeyController@authBegin');
Route::post('/passkey/authenticate/finish', 'PasskeyController@authFinish');

Route::post('/push/token', 'PushOtpController@storeToken');
Route::post('/push/send', 'PushOtpController@sendOtp');
Route::post('/push/verify', 'PushOtpController@verifyOtp');
