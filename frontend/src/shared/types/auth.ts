export type Role = 'USER' | 'TECHNICIAN' | 'MANAGER' | 'ADMIN'

export interface AuthUser {
  id: string
  email: string
  displayName: string
  roles: Role[]
}
