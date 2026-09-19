import { Form, InputGroup } from 'react-bootstrap'

export function TicketFilters({
  keyword,
  status,
  onKeywordChange,
  onStatusChange,
}) {
  return (
    <InputGroup>
      <Form.Control
        aria-label="Search tickets"
        placeholder="Search by code or description"
        value={keyword}
        onChange={(event) => onKeywordChange(event.target.value)}
      />
      <Form.Select
        aria-label="Filter by status"
        value={status}
        onChange={(event) => onStatusChange(event.target.value)}
      >
        <option value="">All statuses</option>
        <option value="SUBMITTED">Submitted</option>
        <option value="UNDER_REVIEW">Under review</option>
        <option value="ASSIGNED">Assigned</option>
        <option value="IN_PROGRESS">In progress</option>
        <option value="RESOLVED">Resolved</option>
        <option value="CLOSED">Closed</option>
      </Form.Select>
    </InputGroup>
  )
}
