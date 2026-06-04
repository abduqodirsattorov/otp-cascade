<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('passkey_credentials', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id'); // Link to users table
            $table->string('credential_id', 255)->unique();
            $table->text('public_key');
            $table->string('user_handle', 64)->nullable();
            $table->unsignedInteger('sign_count')->default(0);
            $table->string('transports')->nullable(); // usb, nfc, ble, internal, hybrid
            $table->timestamps();

            // Index for faster lookups during auth
            $table->index('user_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('passkey_credentials');
    }
};
