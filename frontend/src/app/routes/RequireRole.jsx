import { Navigate, Outlet } from 'react-router'
import { useAuth } from '../../features/auth/context/useAuth'

export function RequireRole({ roles }) {
  const { user } = useAuth()
  const hasRequiredRole =
    user?.roles.some((role) => roles.includes(role)) ?? false

  return hasRequiredRole ? <Outlet /> : <Navigate to="/unauthorized" replace />
}
