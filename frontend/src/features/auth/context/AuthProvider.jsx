import { useCallback, useEffect, useMemo, useState } from 'react'
import { AuthContext } from './auth-context'

const SESSION_KEY = 'nexora.demo-user'

function readDemoUser() {
  const stored = sessionStorage.getItem(SESSION_KEY)
  return stored ? JSON.parse(stored) : null
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
