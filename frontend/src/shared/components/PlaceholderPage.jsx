import { Card, Container } from 'react-bootstrap'

export function PlaceholderPage({ title, description }) {
  return (
    <Container className="page-container">
      <Card className="shadow-sm">
        <Card.Body>
          <h1 className="h3">{title}</h1>
          <p className="text-secondary mb-0">{description}</p>
        </Card.Body>
      </Card>
    </Container>
  )
}
