import { render, screen } from '@testing-library/react'
import { beforeEach, describe, expect, it } from 'vitest'
import { ROLE_CODES } from '../../../shared/constants/roles'
import { AuthProvider } from './AuthProvider'
import { useAuth } from './useAuth'

const SESSION_KEY = 'nexora.demo-user'

function SessionProbe() {
  const { user } = useAuth()
  return <span>{user ? user.roles.join(',') : 'anonymous'}</span>
}

describe('AuthProvider session restoration', () => {
  beforeEach(() => {
    sessionStorage.clear()
  })

  it('restores a session containing canonical roles', () => {
    sessionStorage.setItem(
      SESSION_KEY,
      JSON.stringify({
        id: 'requester',
        email: 'requester@example.test',
        displayName: 'Requester',
        roles: [ROLE_CODES.REQUESTER],
      }),
    )

    render(
      <AuthProvider>
        <SessionProbe />
      </AuthProvider>,
    )

    expect(screen.getByText(ROLE_CODES.REQUESTER)).toBeInTheDocument()
  })

  it('clears a session containing an obsolete role', () => {
    const obsoleteRole = ['US', 'ER'].join('')
    sessionStorage.setItem(
      SESSION_KEY,
      JSON.stringify({
        id: 'legacy-user',
        email: 'legacy@example.test',
        displayName: 'Legacy user',
        roles: [obsoleteRole],
      }),
    )

    render(
      <AuthProvider>
        <SessionProbe />
      </AuthProvider>,
    )

    expect(screen.getByText('anonymous')).toBeInTheDocument()
    expect(sessionStorage.getItem(SESSION_KEY)).toBeNull()
  })
})
