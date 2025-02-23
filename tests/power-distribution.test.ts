import { describe, it, beforeEach, expect } from "vitest"

describe("Power Distribution Contract", () => {
  let mockStorage: Map<string, any>
  let totalPower: number
  
  beforeEach(() => {
    mockStorage = new Map()
    totalPower = 0
  })
  
  const mockContractCall = (method: string, args: any[]) => {
    switch (method) {
      case "allocate-power":
        const [consumerId, amount] = args
        if (totalPower + amount > 1000000) return { success: false, error: 400 }
        const currentAllocation = mockStorage.get(`consumer-${consumerId}`) || 0
        mockStorage.set(`consumer-${consumerId}`, currentAllocation + amount)
        totalPower += amount
        return { success: true }
      
      case "deallocate-power":
        const [deallocationConsumerId, deallocationAmount] = args
        const currentDeallocation = mockStorage.get(`consumer-${deallocationConsumerId}`) || 0
        if (currentDeallocation < deallocationAmount) return { success: false, error: 400 }
        mockStorage.set(`consumer-${deallocationConsumerId}`, currentDeallocation - deallocationAmount)
        totalPower -= deallocationAmount
        return { success: true }
      
      case "get-power-allocation":
        return { success: true, value: { allocated_power: mockStorage.get(`consumer-${args[0]}`) || 0 } }
      
      case "get-total-power":
        return { success: true, value: totalPower }
      
      default:
        return { success: false, error: "Unknown method" }
    }
  }
  
  it("should allocate power", () => {
    const result = mockContractCall("allocate-power", [1, 1000])
    expect(result.success).toBe(true)
  })
  
  it("should not allocate power beyond capacity", () => {
    mockContractCall("allocate-power", [1, 1000000])
    const result = mockContractCall("allocate-power", [2, 1])
    expect(result.success).toBe(false)
    expect(result.error).toBe(400)
  })
  
  it("should deallocate power", () => {
    mockContractCall("allocate-power", [1, 1000])
    const result = mockContractCall("deallocate-power", [1, 500])
    expect(result.success).toBe(true)
  })
  
  it("should get power allocation", () => {
    mockContractCall("allocate-power", [1, 1000])
    const result = mockContractCall("get-power-allocation", [1])
    expect(result.success).toBe(true)
    expect(result.value).toEqual({ allocated_power: 1000 })
  })
  
  it("should get total power", () => {
    mockContractCall("allocate-power", [1, 1000])
    mockContractCall("allocate-power", [2, 2000])
    const result = mockContractCall("get-total-power", [])
    expect(result.success).toBe(true)
    expect(result.value).toBe(3000)
  })
})

