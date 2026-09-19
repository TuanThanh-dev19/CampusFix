import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { ticketApi } from '../api/ticketApi'
import type { TicketSearchParams } from '../types/ticket'

export function useTickets(params: TicketSearchParams) {
  return useQuery({
    queryKey: ['tickets', params],
    queryFn: () => ticketApi.search(params),
    placeholderData: keepPreviousData,
  })
}
