import { Alert } from 'react-bootstrap'

export function EmptyState({ message }: { message: string }) {
  return (
    <Alert variant="light" className="border text-center text-secondary">
      {message}
    </Alert>
  )
}
