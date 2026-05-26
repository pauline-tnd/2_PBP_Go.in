<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    public function show(Request $request)
    {
        return response()->json([
            'data' => $request->user(),
        ], 200);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'profile_image' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        if ($user->profile_image && Storage::disk('public')->exists($user->profile_image)) {
            Storage::disk('public')->delete($user->profile_image);
        }

        $path = $request->file('profile_image')->store('profile_images', 'public');
        $user->update([
            'profile_image' => $path,
        ]);

        return response()->json([
            'message' => 'Profile updated successfully',
            'data' => $user->fresh(),
        ], 200);
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'username' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|max:50',
            'email' => ['sometimes', 'email', 'max:255', Rule::unique('users', 'email')->ignore($user->id, 'id')],
        ]);

        $user->update($validated);

        return response()->json([
            'message' => 'Profile updated successfully',
            'data' => $user->fresh(),
        ], 200);
    }

    public function updatePassword(Request $request)
    {
        $user = $request->user();

        $request->validate(
            [
                'current_password' => 'required|string',
                'new_password' => 'required|string|min:8|confirmed',
            ],
            [
                'current_password.required' => 'Current Password cannot be empty.',
                'new_password.required' => 'New Password cannot be empty.',
                'new_password.min' => 'New Password must be at least 8 characters.',
                'new_password.confirmed' => 'New Password and New Password Confirmation must be the same.',
            ]
        );

        if (! Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'Current Password does not match',
            ], 422);
        }

        $user->update([
            'password' => $request->new_password,
        ]);

        return response()->json([
            'message' => 'Password changed successfully',
        ], 200);
    }

    public function destroy(Request $request)
    {
        $user = $request->user();

        if ($user->profile_image) {
            Storage::disk('public')->delete($user->profile_image);
        }

        if (method_exists($user, 'tokens')) {
            $user->tokens()->delete();
        }

        $user->delete();

        return response()->json([
            'message' => 'Account deleted successfully',
        ], 200);
    }
}
