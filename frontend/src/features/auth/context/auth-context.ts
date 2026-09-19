import { createContext } from 'react'
import type { AuthUser, Role } from '../../../shared/types/auth'

export interface DemoLoginInput {
  email: string
  role: Role
}

export interface AuthContextValue {
  user: AuthUser | null
  isAuthenticated: boolean
  loginDemo: (input: DemoLoginInput) => void
  logout: () => void
}

export const AuthContext = createContext<AuthContextValue | undefined>(undefined)
