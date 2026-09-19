export type DynamicFieldType =
  'TEXT' | 'TEXTAREA' | 'NUMBER' | 'SELECT' | 'DATE' | 'IMAGE'

export interface CategoryFieldDefinition {
  key: string
  label: string
  type: DynamicFieldType
  required: boolean
  options?: string[]
}
