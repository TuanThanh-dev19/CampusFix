import { zodResolver } from '@hookform/resolvers/zod'
import { Button, Form } from 'react-bootstrap'
import { useForm } from 'react-hook-form'
import { ROLE_CODES, ROLE_OPTIONS } from '../../../shared/constants/roles'
import { loginSchema } from '../schemas/authSchema'

export function LoginForm({ onSubmit }) {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: 'student@campus.edu',
      role: ROLE_CODES.REQUESTER,
    },
  })

  return (
    <Form onSubmit={handleSubmit(onSubmit)} noValidate>
      <Form.Group className="mb-3" controlId="email">
        <Form.Label>Email</Form.Label>
        <Form.Control
          type="email"
          isInvalid={Boolean(errors.email)}
          {...register('email')}
        />
        <Form.Control.Feedback type="invalid">
          {errors.email?.message}
        </Form.Control.Feedback>
      </Form.Group>

      <Form.Group className="mb-3" controlId="role">
        <Form.Label>Demo role</Form.Label>
        <Form.Select {...register('role')}>
          {ROLE_OPTIONS.map(({ value, label }) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </Form.Select>
      </Form.Group>

      <Button type="submit" disabled={isSubmitting}>
        Continue
      </Button>
    </Form>
  )
}
