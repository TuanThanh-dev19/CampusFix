export function isApiError(value) {
  return (
    value !== null &&
    typeof value === 'object' &&
    typeof value.status === 'number' &&
    typeof value.title === 'string' &&
    typeof value.detail === 'string'
  )
}
