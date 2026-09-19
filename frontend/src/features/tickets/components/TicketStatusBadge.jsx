import { Badge } from 'react-bootstrap'

const variants = {
  SUBMITTED: 'secondary',
  UNDER_REVIEW: 'info',
  ASSIGNED: 'primary',
  IN_PROGRESS: 'warning',
  RESOLVED: 'success',
  CLOSED: 'dark',
  REJECTED: 'danger',
  CANCELLED: 'secondary',
}

export function TicketStatusBadge({ status }) {
  return <Badge bg={variants[status]}>{status.replaceAll('_', ' ')}</Badge>
}
