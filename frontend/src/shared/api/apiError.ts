export interface ApiFieldError {
  field: string
  message: string
}

export interface ApiError {
  status: number
  title: string
  detail: string
  fieldErrors?: Record<string, string> | ApiFieldError[]
  traceId?: string
}
