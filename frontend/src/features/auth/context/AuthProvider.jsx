import { useCallback, useEffect, useMemo, useState } from 'react'
import { ROLES } from '../../../shared/constants/roles'
import { AuthContext } from './auth-context'

const SESSION_KEY = 'nexora.demo-user'

function isCanonicalDemoUser(value) {
  return (
    value !== null &&
    typeof value === 'object' &&
    typeof value.email === 'string' &&
    Array.isArray(value.roles) &&
    value.roles.length > 0 &&
    value.roles.every((role) => ROLES.includes(role))
  )
}

function readDemoUser() {
  const stored = sessionStorage.getItem(SESSION_KEY)
  if (!stored) {
    return null
  }

  try {
    const parsed = JSON.parse(stored)
    if (isCanonicalDemoUser(parsed)) {
      return parsed
    }
  } catch {
    // Invalid sessions are cleared below and treated as unauthenticated.
  }

  sessionStorage.removeItem(SESSION_KEY)
  return null
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(readDemoUser)

  const logout = useCallback(() => {
    sessionStorage.removeItem(SESSION_KEY)
    setUser(null)
  }, [])

  const loginDemo = useCallback(({ email, role }) => {
    const demoUser = {
      id: 'demo-user',
      email,
      displayName: email.split('@')[0] || 'Nexora User',
      roles: [role],
    }
    sessionStorage.setItem(SESSION_KEY, JSON.stringify(demoUser))
    setUser(demoUser)
  }, [])

  useEffect(() => {
    window.addEventListener('nexora:unauthorized', logout)
    return () => window.removeEventListener('nexora:unauthorized', logout)
  }, [logout])

  const value = useMemo(
    () => ({ user, isAuthenticated: user !== null, loginDemo, logout }),
    [user, loginDemo, logout],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
