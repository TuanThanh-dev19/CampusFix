import { Badge, ListGroup } from 'react-bootstrap'
import type { CategoryFieldDefinition } from '../types/categoryForm'

export function DynamicFieldPreview({
  field,
}: {
  field: CategoryFieldDefinition
}) {
  return (
    <ListGroup.Item className="d-flex justify-content-between align-items-center">
      <span>
        {field.label}
        {field.required && <span className="text-danger ms-1">*</span>}
      </span>
      <Badge bg="light" text="dark">
        {field.type}
      </Badge>
    </ListGroup.Item>
  )
}
