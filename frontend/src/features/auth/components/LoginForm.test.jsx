import { render, screen, within } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'
import { ROLES, ROLE_CODES, ROLE_LABELS } from '../../../shared/constants/roles'
import { LoginForm } from './LoginForm'

describe('LoginForm', () => {
  it('uses requester as the default and exposes every canonical role', () => {
    render(<LoginForm onSubmit={vi.fn()} />)

    const roleSelect = screen.getByRole('combobox', { name: 'Demo role' })
    const options = within(roleSelect).getAllByRole('option')

    expect(roleSelect).toHaveValue(ROLE_CODES.REQUESTER)
    expect(options.map((option) => option.value)).toEqual(ROLES)
    expect(options.map((option) => option.textContent)).toEqual(
      ROLES.map((role) => ROLE_LABELS[role]),
    )
  })
})
