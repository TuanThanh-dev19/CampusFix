import { Alert } from 'react-bootstrap'

export function EmptyState({ message }) {
  return (
    <Alert variant="light" className="border text-center text-secondary">
      {message}
    </Alert>
  )
}
