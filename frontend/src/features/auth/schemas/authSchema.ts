import { z } from 'zod'

export const loginSchema = z.object({
  email: z.string().email('Enter a valid email address'),
  role: z.enum(['USER', 'TECHNICIAN', 'MANAGER', 'ADMIN']),
})

export type LoginValues = z.infer<typeof loginSchema>
