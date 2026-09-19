import { Badge } from 'react-bootstrap'
import type { AssetStatus } from '../types/asset'

const variants: Record<AssetStatus, string> = {
  ACTIVE: 'success',
  UNDER_MAINTENANCE: 'warning',
  OUT_OF_SERVICE: 'danger',
  RETIRED: 'secondary',
}

export function AssetStatusBadge({ status }: { status: AssetStatus }) {
  return <Badge bg={variants[status]}>{status.replaceAll('_', ' ')}</Badge>
}
