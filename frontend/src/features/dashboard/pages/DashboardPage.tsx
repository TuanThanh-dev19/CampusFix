import { Card, Col, Container, Row } from 'react-bootstrap'

const metrics = [
  ['Open tickets', '—'],
  ['In progress', '—'],
  ['SLA at risk', '—'],
  ['Resolved this week', '—'],
]

export function DashboardPage() {
  return (
    <Container className="page-container">
      <h1 className="h2 mb-4">Dashboard</h1>
      <Row className="g-3">
        {metrics.map(([label, value]) => (
          <Col sm={6} xl={3} key={label}>
            <Card className="metric-card shadow-sm">
              <Card.Body>
                <Card.Subtitle className="text-secondary">{label}</Card.Subtitle>
                <div className="display-6 mt-2">{value}</div>
              </Card.Body>
            </Card>
          </Col>
        ))}
      </Row>
    </Container>
  )
}
