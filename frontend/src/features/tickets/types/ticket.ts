export type TicketStatus =
  | 'SUBMITTED'
  | 'UNDER_REVIEW'
  | 'ASSIGNED'
  | 'IN_PROGRESS'
  | 'RESOLVED'
  | 'CLOSED'
  | 'REJECTED'
  | 'CANCELLED'

export interface TicketSummary {
  id: string
  code: string
  title: string
  status: TicketStatus
  categoryName: string
  locationName: string
  createdAt: string
}

export interface TicketSearchParams {
  keyword?: string
  status?: TicketStatus
  page?: number
  size?: number
  sort?: string
}
