import { Badge, Card, Col, Container, Row } from 'react-bootstrap'

const modules = [
  ['Ticket workflow', 'Report → review → assign → repair → resolve → feedback'],
  ['Equipment', 'Types, asset codes, locations, status, and maintenance history'],
  ['Dynamic forms', 'Versioned category fields and server-side validation rules'],
  ['Dashboard', 'Workload, status distribution, turnaround time, and SLA metrics'],
]

export function HomePage() {
  return (
    <Container className="page-container">
      <Badge bg="primary" className="mb-3">
        SBA301 starter
      </Badge>
      <h1>CampusFix</h1>
      <p className="lead text-secondary">
        Campus incident reporting, maintenance workflow, and equipment tracking in one
        focused eight-week project.
      </p>
      <Row className="g-3 mt-3">
        {modules.map(([title, description]) => (
          <Col md={6} key={title}>
            <Card className="h-100 shadow-sm">
              <Card.Body>
                <Card.Title>{title}</Card.Title>
                <Card.Text className="text-secondary">{description}</Card.Text>
              </Card.Body>
            </Card>
          </Col>
        ))}
      </Row>
    </Container>
  )
}
