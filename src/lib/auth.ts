import type { AuthError, Session } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'

export type AuthResult = {
  session: Session | null
  error: AuthError | null
}

export const signUpWithEmail = async (
  email: string,
  password: string,
  fullName: string,
): Promise<AuthResult> => {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName,
      },
    },
  })

  return { session: data.session, error }
}

export const signInWithEmail = async (email: string, password: string): Promise<AuthResult> => {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  return { session: data.session, error }
}

export const signOut = async () => {
  const { error } = await supabase.auth.signOut()
  return { error }
}
