import { httpClient } from '../../../shared/api/httpClient'
import type { TicketSearchParams, TicketSummary } from '../types/ticket'

interface PageResponse<T> {
  content: T[]
  page: number
  size: number
  totalElements: number
  totalPages: number
}

export const ticketApi = {
  async search(params: TicketSearchParams) {
    const response = await httpClient.get<PageResponse<TicketSummary>>(
      '/tickets',
      { params },
    )
    return response.data
  },
}
