import { Form, InputGroup } from 'react-bootstrap'
import { TICKET_STATUS_OPTIONS } from '../constants/ticketStatuses'

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
        {TICKET_STATUS_OPTIONS.map(({ value, label }) => (
          <option key={value} value={value}>
            {label}
          </option>
        ))}
      </Form.Select>
    </InputGroup>
  )
}
