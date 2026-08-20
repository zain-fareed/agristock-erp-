import { Navigate, Outlet } from 'react-router-dom'
import { useAuthSession } from '@/lib/use-auth-session'

export const ProtectedRoute = () => {
  const { session, loading } = useAuthSession()

  if (loading) {
    return <div className="p-6 text-sm text-muted-foreground">Checking session...</div>
  }

  if (!session) {
    return <Navigate to="/sign-in" replace />
  }

  return <Outlet />
}
