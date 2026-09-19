import { useState } from 'react'
import { Button, Card, Container, Stack } from 'react-bootstrap'
import { TicketFilters } from '../components/TicketFilters'

export function TicketListPage() {
  const [keyword, setKeyword] = useState('')
  const [status, setStatus] = useState('')

  return (
    <Container className="page-container">
      <Stack direction="horizontal" className="justify-content-between mb-4">
        <div>
          <h1 className="h2 mb-1">Tickets</h1>
          <p className="text-secondary mb-0">
            Search, filter, sort, and paginate tickets here.
          </p>
        </div>
        <Button>Create ticket</Button>
      </Stack>
      <Card className="shadow-sm">
        <Card.Body>
          <TicketFilters
            keyword={keyword}
            status={status}
            onKeywordChange={setKeyword}
            onStatusChange={setStatus}
          />
          <p className="text-secondary text-center my-5">
            Connect this page to <code>useTickets</code> after the ticket API is
            implemented.
          </p>
        </Card.Body>
      </Card>
    </Container>
  )
}
