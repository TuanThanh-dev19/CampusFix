import { zodResolver } from '@hookform/resolvers/zod'
import { Alert, Button, Card, Container, Form } from 'react-bootstrap'
import { useForm } from 'react-hook-form'
import { useLocation, useNavigate } from 'react-router'
import { z } from 'zod'
import { useAuth } from '../context/useAuth'

const loginSchema = z.object({
  email: z.string().email('Enter a valid email address'),
  role: z.enum(['USER', 'TECHNICIAN', 'MANAGER', 'ADMIN']),
})

type LoginValues = z.infer<typeof loginSchema>

export function LoginPage() {
  const { loginDemo } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: 'student@campus.edu', role: 'USER' },
  })

  const onSubmit = (values: LoginValues) => {
    loginDemo(values)
    const redirect = (location.state as { from?: string } | null)?.from ?? '/dashboard'
    navigate(redirect, { replace: true })
  }

  return (
    <Container className="page-container page-narrow">
      <Card className="shadow-sm">
        <Card.Body className="p-4">
          <h1 className="h3">CampusFix sign in</h1>
          <Alert variant="warning" className="small">
            This starter uses a UI-only demo session. Replace <code>loginDemo</code> with the
            Spring Boot authentication API before implementing real accounts.
          </Alert>
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
            <Button type="submit">Continue</Button>
          </Form>
        </Card.Body>
      </Card>
    </Container>
  )
}
