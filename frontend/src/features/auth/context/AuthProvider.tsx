import {
  type ReactNode,
  useCallback,
  useEffect,
  useMemo,
  useState,
} from 'react'
import type { AuthUser } from '../../../shared/types/auth'
import { AuthContext, type DemoLoginInput } from './auth-context'

const SESSION_KEY = 'campusfix.demo-user'

function readDemoUser(): AuthUser | null {
  const stored = sessionStorage.getItem(SESSION_KEY)
  return stored ? (JSON.parse(stored) as AuthUser) : null
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(readDemoUser)

  const logout = useCallback(() => {
    sessionStorage.removeItem(SESSION_KEY)
    setUser(null)
  }, [])

  const loginDemo = useCallback(({ email, role }: DemoLoginInput) => {
    const demoUser: AuthUser = {
      id: 'demo-user',
      email,
      displayName: email.split('@')[0] || 'CampusFix User',
      roles: [role],
    }
    sessionStorage.setItem(SESSION_KEY, JSON.stringify(demoUser))
    setUser(demoUser)
  }, [])

  useEffect(() => {
    window.addEventListener('campusfix:unauthorized', logout)
    return () => window.removeEventListener('campusfix:unauthorized', logout)
  }, [logout])

  const value = useMemo(
    () => ({ user, isAuthenticated: user !== null, loginDemo, logout }),
    [user, loginDemo, logout],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
