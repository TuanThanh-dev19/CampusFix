import { Card } from 'react-bootstrap'

export function MetricCard({ label, value }) {
  return (
    <Card className="metric-card h-100 shadow-sm">
      <Card.Body>
        <Card.Subtitle className="text-secondary">{label}</Card.Subtitle>
        <div className="display-6 mt-2">{value}</div>
      </Card.Body>
    </Card>
  )
}
