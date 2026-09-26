import { z } from 'zod'
import { ROLES } from '../../../shared/constants/roles'

export const loginSchema = z.object({
  email: z.string().email('Enter a valid email address'),
  role: z.enum(ROLES),
})
