import { zodResolver } from '@hookform/resolvers/zod'
import { Button, Form } from 'react-bootstrap'
import { useForm } from 'react-hook-form'
import { loginSchema, type LoginValues } from '../schemas/authSchema'

interface LoginFormProps {
  onSubmit: (values: LoginValues) => void
}

export function LoginForm({ onSubmit }: LoginFormProps) {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: 'student@campus.edu', role: 'USER' },
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
          <option value="USER">User</option>
          <option value="TECHNICIAN">Technician</option>
          <option value="MANAGER">Manager</option>
          <option value="ADMIN">Admin</option>
        </Form.Select>
      </Form.Group>

      <Button type="submit" disabled={isSubmitting}>
        Continue
      </Button>
    </Form>
  )
}
