<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'username' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
            'phone' => 'required|string|max:50',
        ]);

        $user = User::create($validated);

        return response()->json([
            'message' => 'User created successfully',
            'user' => $user,
        ], 201);
    }

    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        if (!Auth::attempt($validated)) {
            return response()->json([
                'message' => 'Email or Password incorrect.',
            ], 401);
        }

        $user = $request->user();

        $user->tokens()->delete();
        
        $token = $user->createToken('Personal Access Token')->plainTextToken;

        return response()->json([
            'message' => 'User logged in successfully',
            'user' => $user,
            'token' => $token,
        ], 200);
    }

    public function googleLogin(Request $request)
    {
        $validated = $request->validate([
            'id_token' => 'nullable|string|required_without:access_token',
            'access_token' => 'nullable|string|required_without:id_token',
        ]);

        [$googleUser, $errorMessage] = $this->resolveGoogleUser($validated);

        if ($googleUser === null) {
            return response()->json([
                'message' => $errorMessage ?? 'Invalid Google token.',
            ], 401);
        }

        $email = $googleUser['email'] ?? null;
        $emailVerified = filter_var(
            $googleUser['email_verified'] ?? false,
            FILTER_VALIDATE_BOOLEAN
        );

        if (! $email || ! $emailVerified) {
            return response()->json([
                'message' => 'Google account email is not verified.',
            ], 401);
        }

        $user = User::firstOrNew(['email' => $email]);

        if (! $user->exists) {
            $user->username = $this->buildGoogleUsername(
                $googleUser['name'] ?? explode('@', $email)[0]
            );
            $user->email = $email;
            $user->password = Str::random(40);
            $user->phone = 'google-account';
            $user->profile_image = $googleUser['picture'] ?? null;
            $user->save();
        } else {
            $shouldSave = false;

            if (! $user->username) {
                $user->username = $this->buildGoogleUsername(
                    $googleUser['name'] ?? explode('@', $email)[0]
                );
                $shouldSave = true;
            }

            if (! $user->profile_image && ! empty($googleUser['picture'])) {
                $user->profile_image = $googleUser['picture'];
                $shouldSave = true;
            }

            if (! $user->phone) {
                $user->phone = 'google-account';
                $shouldSave = true;
            }

            if ($shouldSave) {
                $user->save();
            }
        }

        $user->tokens()->delete();
        $token = $user->createToken('Personal Access Token')->plainTextToken;

        return response()->json([
            'message' => 'User logged in successfully',
            'user' => $user,
            'token' => $token,
        ], 200);
    }

    public function logout() {

        $user = Auth::user();

        if(!$user){
            return response()->json([
                'message' => 'Not authorized',
            ], 401);
        }

        $user->currentAccessToken()->delete();
        
        return response()->json([
            'message'=> 'Logged out successfully',
        ], 200);
    }

    private function buildGoogleUsername(string $value): string
    {
        $username = Str::of($value)
            ->lower()
            ->replaceMatches('/[^a-z0-9._-]+/', '.')
            ->trim('.');

        return $username->isNotEmpty()
            ? $username->toString()
            : 'google.user';
    }

    private function resolveGoogleUser(array $validated): array
    {
        if (! empty($validated['id_token'])) {
            $response = Http::acceptJson()->get(
                'https://oauth2.googleapis.com/tokeninfo',
                ['id_token' => $validated['id_token']]
            );

            if (! $response->ok()) {
                return [null, 'Invalid Google ID token.'];
            }

            $googleUser = $response->json();
            $expectedClientId = config('services.google.client_id');
            $audience = $googleUser['aud'] ?? null;

            if ($expectedClientId && $audience !== $expectedClientId) {
                return [null, 'Google token audience mismatch.'];
            }

            return [$googleUser, null];
        }

        $response = Http::acceptJson()
            ->withToken($validated['access_token'])
            ->get('https://www.googleapis.com/oauth2/v3/userinfo');

        if (! $response->ok()) {
            return [null, 'Invalid Google access token.'];
        }

        return [$response->json(), null];
    }
}
