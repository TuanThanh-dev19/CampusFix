import { Badge, ListGroup } from 'react-bootstrap'

export function DynamicFieldPreview({ field }) {
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
