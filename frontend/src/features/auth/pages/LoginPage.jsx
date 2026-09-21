import { Alert, Card, Container } from 'react-bootstrap'
import { useLocation, useNavigate } from 'react-router'
import { LoginForm } from '../components/LoginForm'
import { useAuth } from '../context/useAuth'

export function LoginPage() {
  const { loginDemo } = useAuth()
  const navigate = useNavigate()
  const location = useLocation()

  const handleLogin = (values) => {
    loginDemo(values)
    const redirect = location.state?.from ?? '/dashboard'
    navigate(redirect, { replace: true })
  }

  return (
    <Container className="page-container page-narrow">
      <Card className="shadow-sm">
        <Card.Body className="p-4">
          <h1 className="h3">Nexora sign in</h1>
          <Alert variant="warning" className="small">
            This starter uses a UI-only demo session. Replace{' '}
            <code>loginDemo</code> with the Spring Boot authentication API
            before implementing real accounts.
          </Alert>
          <LoginForm onSubmit={handleLogin} />
        </Card.Body>
      </Card>
    </Container>
  )
}
