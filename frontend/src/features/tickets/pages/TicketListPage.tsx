import { Button, Card, Container, Form, InputGroup, Stack } from 'react-bootstrap'

export function TicketListPage() {
  return (
    <Container className="page-container">
      <Stack direction="horizontal" className="justify-content-between mb-4">
        <div>
          <h1 className="h2 mb-1">Tickets</h1>
          <p className="text-secondary mb-0">Search, filter, sort, and paginate tickets here.</p>
        </div>
        <Button>Create ticket</Button>
      </Stack>
      <Card className="shadow-sm">
        <Card.Body>
          <InputGroup>
            <Form.Control aria-label="Search tickets" placeholder="Search by code or description" />
            <Form.Select aria-label="Filter by status" defaultValue="">
              <option value="">All statuses</option>
              <option value="SUBMITTED">Submitted</option>
              <option value="ASSIGNED">Assigned</option>
              <option value="IN_PROGRESS">In progress</option>
              <option value="RESOLVED">Resolved</option>
            </Form.Select>
          </InputGroup>
          <p className="text-secondary text-center my-5">
            Connect this page to <code>GET /api/v1/tickets</code> with a feature query hook.
          </p>
        </Card.Body>
      </Card>
    </Container>
  )
}
