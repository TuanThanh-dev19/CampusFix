import { Col, Container, Row } from 'react-bootstrap'
import { MetricCard } from '../components/MetricCard'

const metrics = [
  { label: 'Open tickets', value: '—' },
  { label: 'In progress', value: '—' },
  { label: 'SLA at risk', value: '—' },
  { label: 'Resolved this week', value: '—' },
]

export function DashboardPage() {
  return (
    <Container className="page-container">
      <h1 className="h2 mb-4">Dashboard</h1>
      <Row className="g-3">
        {metrics.map((metric) => (
          <Col sm={6} xl={3} key={metric.label}>
            <MetricCard {...metric} />
          </Col>
        ))}
      </Row>
    </Container>
  )
}
