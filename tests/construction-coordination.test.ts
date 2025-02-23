import { describe, it, beforeEach, expect } from "vitest"

describe("Construction Coordination Contract", () => {
  let mockStorage: Map<string, any>
  let nextTaskId: number
  
  beforeEach(() => {
    mockStorage = new Map()
    nextTaskId = 0
  })
  
  const mockContractCall = (method: string, args: any[]) => {
    switch (method) {
      case "create-task":
        const [moduleId, taskType, priority] = args
        nextTaskId++
        mockStorage.set(`task-${nextTaskId}`, {
          module_id: moduleId,
          task_type: taskType,
          priority,
          status: "pending",
        })
        return { success: true, value: nextTaskId }
      
      case "update-task-status":
        const [taskId, newStatus] = args
        const task = mockStorage.get(`task-${taskId}`)
        if (!task) return { success: false, error: 404 }
        task.status = newStatus
        return { success: true }
      
      case "get-task":
        return { success: true, value: mockStorage.get(`task-${args[0]}`) }
      
      default:
        return { success: false, error: "Unknown method" }
    }
  }
  
  it("should create a task", () => {
    const result = mockContractCall("create-task", [1, "assembly", 2])
    expect(result.success).toBe(true)
    expect(result.value).toBe(1)
  })
  
  it("should update task status", () => {
    mockContractCall("create-task", [1, "assembly", 2])
    const result = mockContractCall("update-task-status", [1, "in-progress"])
    expect(result.success).toBe(true)
  })
  
  it("should get task information", () => {
    mockContractCall("create-task", [1, "assembly", 2])
    const result = mockContractCall("get-task", [1])
    expect(result.success).toBe(true)
    expect(result.value).toEqual({
      module_id: 1,
      task_type: "assembly",
      priority: 2,
      status: "pending",
    })
  })
})

