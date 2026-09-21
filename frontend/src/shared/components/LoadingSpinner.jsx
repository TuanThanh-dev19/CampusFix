import { Spinner } from 'react-bootstrap'

export function LoadingSpinner({ label = 'Loading' }) {
  return (
    <div
      className="d-flex align-items-center justify-content-center gap-2 py-5"
      role="status"
    >
      <Spinner animation="border" size="sm" aria-hidden="true" />
      <span>{label}</span>
    </div>
  )
}
