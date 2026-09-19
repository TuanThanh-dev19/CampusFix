import { Badge } from 'react-bootstrap'
import type { TicketStatus } from '../types/ticket'

const variants: Record<TicketStatus, string> = {
  SUBMITTED: 'secondary',
  UNDER_REVIEW: 'info',
  ASSIGNED: 'primary',
  IN_PROGRESS: 'warning',
  RESOLVED: 'success',
  CLOSED: 'dark',
  REJECTED: 'danger',
  CANCELLED: 'secondary',
}

export function TicketStatusBadge({ status }: { status: TicketStatus }) {
  return <Badge bg={variants[status]}>{status.replaceAll('_', ' ')}</Badge>
}
