import { useMemo } from 'react'
import { signOut } from '@/lib/auth'
import { useAuthSession } from '@/lib/use-auth-session'

export const ProtectedHomePage = () => {
  const { session } = useAuthSession()

  const email = useMemo(() => session?.user.email ?? 'Unknown user', [session?.user.email])

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col gap-6 p-6">
      <h1 className="text-2xl font-semibold">AgriStock ERP PHASE 1</h1>
      <p className="text-sm text-muted-foreground">Protected route and Supabase auth are configured.</p>
      <div className="rounded-md border bg-card p-4 text-card-foreground">
        <p className="text-sm">Signed in as: {email}</p>
      </div>
      <button
        className="w-fit rounded-md border px-4 py-2 text-sm"
        onClick={() => {
          void signOut()
        }}
        type="button"
      >
        Sign out
      </button>
    </main>
  )
}
