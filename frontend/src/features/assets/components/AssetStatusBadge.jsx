import { Badge } from 'react-bootstrap'

const variants = {
  ACTIVE: 'success',
  UNDER_MAINTENANCE: 'warning',
  OUT_OF_SERVICE: 'danger',
  RETIRED: 'secondary',
}

export function AssetStatusBadge({ status }) {
  return <Badge bg={variants[status]}>{status.replaceAll('_', ' ')}</Badge>
}
