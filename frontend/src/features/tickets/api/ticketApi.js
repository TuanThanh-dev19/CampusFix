import { httpClient } from '../../../shared/api/httpClient'

export const ticketApi = {
  async search(params) {
    const response = await httpClient.get('/tickets', { params })
    return response.data
  },
}
