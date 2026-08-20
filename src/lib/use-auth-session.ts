import { useEffect, useState } from 'react'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'

export const useAuthSession = () => {
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let subscribed = true

    const loadSession = async () => {
      const { data } = await supabase.auth.getSession()
      if (subscribed) {
        setSession(data.session)
        setLoading(false)
      }
    }

    void loadSession()

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      setSession(nextSession)
      setLoading(false)
    })

    return () => {
      subscribed = false
      subscription.unsubscribe()
    }
  }, [])

  return { session, loading }
}
