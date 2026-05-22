<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Firebase\JWT\ExpiredException;

class SupabaseAuth
{
    public function handle(Request $request, Closure $next)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(['error' => 'No token provided'], 401);
        }

        try {
            $decoded = JWT::decode(
                $token,
                new Key(env('SUPABASE_JWT_SECRET'), 'HS256')
            );

            // Attach user data to request
            $request->merge([
                'supabase_user_id' => $decoded->sub,
                'supabase_email'   => $decoded->email ?? null,
                'supabase_role'    => $decoded->role ?? 'anon',
            ]);

        } catch (ExpiredException $e) {
            return response()->json(['error' => 'Token expired'], 401);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Invalid token'], 401);
        }

        return $next($request);
    }
}