export type AssetStatus =
  'ACTIVE' | 'UNDER_MAINTENANCE' | 'OUT_OF_SERVICE' | 'RETIRED'

export interface AssetSummary {
  id: string
  assetCode: string
  name: string
  typeName: string
  locationName: string
  status: AssetStatus
}
