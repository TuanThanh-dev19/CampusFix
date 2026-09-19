import { Navigate, Outlet } from 'react-router'
import { useAuth } from '../../features/auth/context/useAuth'
import type { Role } from '../../shared/types/auth'

export function RequireRole({ roles }: { roles: Role[] }) {
  const { user } = useAuth()
  const hasRequiredRole =
    user?.roles.some((role) => roles.includes(role)) ?? false

  return hasRequiredRole ? <Outlet /> : <Navigate to="/unauthorized" replace />
}
