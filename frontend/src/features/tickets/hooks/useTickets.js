import { keepPreviousData, useQuery } from '@tanstack/react-query'
import { ticketApi } from '../api/ticketApi'

export function useTickets(params) {
  return useQuery({
    queryKey: ['tickets', params],
    queryFn: () => ticketApi.search(params),
    placeholderData: keepPreviousData,
  })
}
