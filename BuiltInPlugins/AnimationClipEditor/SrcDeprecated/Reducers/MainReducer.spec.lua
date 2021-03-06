return function()
	local Plugin = script.Parent.Parent.Parent
	local Rodux = require(Plugin.Rodux)
	local isEmpty = require(Plugin.SrcDeprecated.Util.isEmpty)
	local Constants = require(Plugin.SrcDeprecated.Util.Constants)

	local MainReducer = require(script.Parent.MainReducer)

	local SetClipboard = require(Plugin.SrcDeprecated.Actions.SetClipboard)
	local SetAnimationData = require(Plugin.SrcDeprecated.Actions.SetAnimationData)
	local PasteKeyframes = require(Plugin.SrcDeprecated.Thunks.PasteKeyframes)
	local SetAnalytics = require(Plugin.SrcDeprecated.Actions.SetAnalytics)

	local SelectKeyframe = require(Plugin.SrcDeprecated.Thunks.Selection.SelectKeyframe)
	local DeselectKeyframe = require(Plugin.SrcDeprecated.Thunks.Selection.DeselectKeyframe)
	local SelectKeyframesAtFrame = require(Plugin.SrcDeprecated.Thunks.Selection.SelectKeyframesAtFrame)
	local SelectAllKeyframes = require(Plugin.SrcDeprecated.Thunks.Selection.SelectAllKeyframes)
	local CopySelectedKeyframes = require(Plugin.SrcDeprecated.Thunks.Selection.CopySelectedKeyframes)
	local DeleteSelectedKeyframes = require(Plugin.SrcDeprecated.Thunks.Selection.DeleteSelectedKeyframes)
	local ResetSelectedKeyframes = require(Plugin.SrcDeprecated.Thunks.Selection.ResetSelectedKeyframes)
	local MoveSelectedKeyframes = require(Plugin.SrcDeprecated.Thunks.Selection.MoveSelectedKeyframes)
	local ScaleSelectedKeyframes = require(Plugin.SrcDeprecated.Thunks.Selection.ScaleSelectedKeyframes)
	local SetSelectedKeyframeData = require(Plugin.SrcDeprecated.Thunks.Selection.SetSelectedKeyframeData)
	local SetEditingLength = require(Plugin.SrcDeprecated.Actions.SetEditingLength)
	local UpdateEditingLength = require(Plugin.SrcDeprecated.Thunks.UpdateEditingLength)
	local SnapToNearestKeyframe = require(Plugin.SrcDeprecated.Thunks.SnapToNearestKeyframe)
	local SetRootInstance = require(Plugin.SrcDeprecated.Actions.SetRootInstance)
	local ToggleSnapToKeys = require(Plugin.SrcDeprecated.Thunks.ToggleSnapToKeys)
	local SetSnapToKeys = require(Plugin.SrcDeprecated.Actions.SetSnapToKeys)
	local SetActive = require(Plugin.SrcDeprecated.Actions.SetActive)
	local RenameKeyframe = require(Plugin.SrcDeprecated.Thunks.RenameKeyframe)

	local SelectEvent = require(Plugin.SrcDeprecated.Thunks.Events.SelectEvent)
	local DeselectEvent = require(Plugin.SrcDeprecated.Thunks.Events.DeselectEvent)
	local CopySelectedEvents = require(Plugin.SrcDeprecated.Thunks.Events.CopySelectedEvents)
	local PasteEvents = require(Plugin.SrcDeprecated.Thunks.Events.PasteEvents)
	local DeleteSelectedEvents = require(Plugin.SrcDeprecated.Thunks.Events.DeleteSelectedEvents)
	local MoveSelectedEvents = require(Plugin.SrcDeprecated.Thunks.Events.MoveSelectedEvents)
	local SetEvents = require(Plugin.SrcDeprecated.Thunks.Events.SetEvents)

	local SetPlayhead = require(Plugin.SrcDeprecated.Actions.SetPlayhead)
	local AddTrack = require(Plugin.SrcDeprecated.Thunks.AddTrack)
	local SkipAnimation = require(Plugin.SrcDeprecated.Thunks.Playback.SkipAnimation)

	local testAnimationData = {
		Metadata = {
			FrameRate = 30,
			StartFrame = 0,
			EndFrame = 8,
		},
		Events = {
			NamedKeyframes = {},
			Keyframes = {1, 2, 3},
			Data = {
				[1] = {
					TestEvent = "TestValue",
				},
				[2] = {
					TestEvent = "OtherValue",
					OtherEvent = "TestValue",
				},
				[3] = {
					TestEvent = "FinalValue",
					OtherEvent = "OtherValue",
					FinalEvent = "TestValue",
				},
			},
		},
		Instances = {
			Root = {
				Tracks = {
					["TestTrack"] = {
						Keyframes = {1, 2, 3},
						Data = {
							[1] = {
								Value = 1,
							},
							[2] = {
								Value = 2,
							},
							[3] = {
								Value = 3,
							},
						}
					},
					["OtherTrack"] = {
						Keyframes = {1, 4, 6, 8},
						Data = {
							[1] = {
								Value = 1,
							},
							[4] = {
								Value = 4,
							},
							[6] = {
								Value = 6,
							},
							[8] = {
								Value = 8,
							},
						}
					}
				},
			},
		},
	}

	local function createTestStore()
		local middlewares = {Rodux.thunkMiddleware}
		local store = Rodux.Store.new(MainReducer, nil, middlewares)
		store:dispatch(SetAnimationData(testAnimationData))
		store:dispatch(SetActive(true))
		return store
	end

	it("should return a table with the correct members", function()
		local state = MainReducer(nil, {})

		expect(type(state)).to.equal("table")
		expect(state.Status).to.be.ok()
		expect(state.History).to.be.ok()
		expect(state.Notifications).to.be.ok()
		expect(state.Analytics).to.be.ok()
	end)

	describe("SelectKeyframe", function()
		it("should select a keyframe", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1))

			local status = store:getState().Status
			expect(status.SelectedKeyframes).to.be.ok()
			expect(status.SelectedKeyframes.Root).to.be.ok()
			expect(status.SelectedKeyframes.Root.TestTrack).to.be.ok()
			expect(status.SelectedKeyframes.Root.TestTrack[1]).to.be.ok()
		end)

		it("should be able to multi-select keyframes", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))

			local status = store:getState().Status
			local testTrack = status.SelectedKeyframes.Root.TestTrack
			expect(#testTrack).to.equal(2)
		end)

		it("should be able to select keyframes from multiple tracks", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "OtherTrack", 1, true))

			local status = store:getState().Status
			local testTrack = status.SelectedKeyframes.Root.TestTrack
			local otherTrack = status.SelectedKeyframes.Root.OtherTrack
			expect(#testTrack).to.equal(1)
			expect(#otherTrack).to.equal(1)
		end)

		it("should not select the same keyframe twice", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))

			local status = store:getState().Status
			local testTrack = status.SelectedKeyframes.Root.TestTrack
			expect(#testTrack).to.equal(1)
		end)

		it("should clobber selection if not multi-selecting", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2))

			local status = store:getState().Status
			local testTrack = status.SelectedKeyframes.Root.TestTrack
			expect(testTrack[2]).to.be.ok()
		end)
	end)

	describe("DeselectKeyframe", function()
		it("should deselect a keyframe", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(DeselectKeyframe("Root", "TestTrack", 1))

			local status = store:getState().Status
			local testTrack = status.SelectedKeyframes.Root.TestTrack
			expect(testTrack[2]).to.be.ok()
			expect(testTrack[1]).never.to.be.ok()
		end)

		it("should remove a track if no keyframes are selected", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "OtherTrack", 1, true))
			store:dispatch(DeselectKeyframe("Root", "TestTrack", 1))

			local status = store:getState().Status
			local root = status.SelectedKeyframes.Root
			expect(root.TestTrack).never.to.be.ok()
			expect(root.OtherTrack).to.be.ok()
		end)

		it("should remove an instance if no tracks are selected", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(DeselectKeyframe("Root", "TestTrack", 1))

			local status = store:getState().Status
			local root = status.SelectedKeyframes.Root
			expect(root).never.to.be.ok()
			expect(isEmpty(status.SelectedKeyframes)).to.equal(true)
		end)
	end)

	describe("SetSelectedKeyframeData", function()
		it("should set all selected keyframes' EasingDirections", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SetSelectedKeyframeData({
				EasingDirection = Enum.PoseEasingDirection.In,
			}))

			local data = store:getState().AnimationData
			local testTrack = data.Instances.Root.Tracks.TestTrack
			expect(testTrack.Data[1].EasingDirection).to.equal(Enum.PoseEasingDirection.In)
		end)

		it("should set all selected keyframes' EasingStyles", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SetSelectedKeyframeData({
				EasingStyle = Enum.PoseEasingStyle.Linear,
			}))

			local data = store:getState().AnimationData
			local testTrack = data.Instances.Root.Tracks.TestTrack
			expect(testTrack.Data[1].EasingStyle).to.equal(Enum.PoseEasingStyle.Linear)
		end)

		it("should set all selected keyframes' Values", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SetSelectedKeyframeData({
				Value = CFrame.new(1, 0, 0)
			}))

			local data = store:getState().AnimationData
			local testTrack = data.Instances.Root.Tracks.TestTrack
			expect(testTrack.Data[1].Value).to.equal(CFrame.new(1, 0, 0))
		end)
	end)

	describe("PasteKeyframes", function()
		it("should add a new keyframe if none existed", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1))
			store:dispatch(CopySelectedKeyframes())
			store:dispatch(PasteKeyframes(4))

			local data = store:getState().AnimationData
			local testTrack = data.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(4)
			expect(testTrack.Keyframes[4]).to.equal(4)
			expect(testTrack.Data[4]).to.be.ok()
			expect(testTrack.Data[4].Value).to.equal(1)
		end)

		it("should replace an old keyframe if one existed", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1))
			store:dispatch(CopySelectedKeyframes())
			store:dispatch(PasteKeyframes(3))

			local data = store:getState().AnimationData
			local testTrack = data.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(3)
			expect(testTrack.Data[3]).to.be.ok()
			expect(testTrack.Data[3].Value).to.equal(1)
		end)

		it("should paste all keyframes if multiple were copied", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(SelectKeyframe("Root", "OtherTrack", 1, true))
			store:dispatch(CopySelectedKeyframes())
			store:dispatch(PasteKeyframes(4))

			local data = store:getState().AnimationData
			local tracks = data.Instances.Root.Tracks
			local testTrack = tracks.TestTrack
			local otherTrack = tracks.OtherTrack

			expect(#testTrack.Keyframes).to.equal(5)
			expect(testTrack.Data[4]).to.be.ok()
			expect(testTrack.Data[4].Value).to.equal(1)
			expect(testTrack.Data[5]).to.be.ok()
			expect(testTrack.Data[5].Value).to.equal(2)

			expect(#otherTrack.Keyframes).to.equal(4)
			expect(otherTrack.Data[4]).to.be.ok()
			expect(otherTrack.Data[4].Value).to.equal(1)
		end)
	end)

	describe("SelectKeyframesAtFrame", function()
		it("should only select keyframes that match the frame", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframesAtFrame(2))

			local status = store:getState().Status
			local root = status.SelectedKeyframes.Root
			expect(root.TestTrack).to.be.ok()
			expect(root.OtherTrack).never.to.be.ok()
		end)

		it("should replace the current selection if not multi-selecting", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 3))

			local status = store:getState().Status
			local testTrack = status.SelectedKeyframes.Root.TestTrack
			expect(testTrack[3]).to.be.ok()

			store:dispatch(SelectKeyframesAtFrame(1))
			status = store:getState().Status
			local root = status.SelectedKeyframes.Root
			expect(root.TestTrack[1]).to.be.ok()
			expect(root.TestTrack[3]).never.to.be.ok()
			expect(root.OtherTrack[1]).to.be.ok()
		end)

		it("should add to current selection if multi-selecting", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 3))

			local status = store:getState().Status
			local testTrack = status.SelectedKeyframes.Root.TestTrack
			expect(testTrack[3]).to.be.ok()

			store:dispatch(SelectKeyframesAtFrame(1, true))
			status = store:getState().Status
			local root = status.SelectedKeyframes.Root
			expect(root.TestTrack[1]).to.be.ok()
			expect(root.TestTrack[3]).to.be.ok()
			expect(root.OtherTrack[1]).to.be.ok()
		end)
	end)

	describe("SelectAllKeyframes", function()
		it("should select all keyframes across all tracks", function()
			local store = createTestStore()
			store:dispatch(SelectAllKeyframes())

			local status = store:getState().Status
			local root = status.SelectedKeyframes.Root
			expect(root.TestTrack[1]).to.be.ok()
			expect(root.TestTrack[2]).to.be.ok()
			expect(root.TestTrack[3]).to.be.ok()
			expect(root.OtherTrack[1]).to.be.ok()
			expect(root.OtherTrack[4]).to.be.ok()
			expect(root.OtherTrack[6]).to.be.ok()
			expect(root.OtherTrack[8]).to.be.ok()
		end)
	end)

	describe("CopySelectedKeyframes", function()
		it("should copy the keyframes in the selection to the clipboard", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(CopySelectedKeyframes())

			local status = store:getState().Status
			local testTrack = status.Clipboard.Root.TestTrack
			expect(#testTrack).to.equal(2)
			expect(testTrack[1].Value).to.equal(1)
			expect(testTrack[2].Value).to.equal(2)
		end)

		it("should replace the old clipboard", function()
			local store = createTestStore()
			store:dispatch(SetClipboard({TestKey = "TestValue"}))

			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(CopySelectedKeyframes())

			local status = store:getState().Status
			expect(status.Clipboard.TestKey).never.to.be.ok()
		end)
	end)

	describe("DeleteSelectedKeyframes", function()
		it("should delete all selected keyframes", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(DeleteSelectedKeyframes())

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(1)
			expect(testTrack.Keyframes[1]).to.equal(3)
			expect(testTrack.Data[1]).never.to.be.ok()
			expect(testTrack.Data[2]).never.to.be.ok()
			expect(testTrack.Data[3]).to.be.ok()
		end)
	end)

	describe("ResetSelectedKeyframes", function()
		it("should reset all selected keyframes to the base pose", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(ResetSelectedKeyframes())

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(testTrack.Data[1].Value).to.equal(CFrame.new())
			expect(testTrack.Data[1].Value).to.equal(CFrame.new())
		end)
	end)

	describe("MoveSelectedKeyframes", function()
		it("should move the selected keyframes", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(MoveSelectedKeyframes(1, 4))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(3)
			expect(testTrack.Keyframes[1]).to.equal(3)
			expect(testTrack.Keyframes[2]).to.equal(4)
			expect(testTrack.Keyframes[3]).to.equal(5)
		end)

		it("should move relative to the pivot", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(MoveSelectedKeyframes(2, 5))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(3)
			expect(testTrack.Keyframes[1]).to.equal(3)
			expect(testTrack.Keyframes[2]).to.equal(4)
			expect(testTrack.Keyframes[3]).to.equal(5)
		end)

		it("should not clobber keyframes that are being moved forward", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 3, true))
			store:dispatch(MoveSelectedKeyframes(1, 2))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(3)
			expect(testTrack.Keyframes[1]).to.equal(2)
			expect(testTrack.Keyframes[2]).to.equal(3)
			expect(testTrack.Keyframes[3]).to.equal(4)
		end)

		it("should not clobber keyframes that are being moved backward", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 3, true))
			store:dispatch(MoveSelectedKeyframes(3, 2))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(3)
			expect(testTrack.Keyframes[1]).to.equal(0)
			expect(testTrack.Keyframes[2]).to.equal(1)
			expect(testTrack.Keyframes[3]).to.equal(2)
		end)

		it("should clobber existing keyframes that are overlapped", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(MoveSelectedKeyframes(1, 2))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(2)
			expect(testTrack.Keyframes[1]).to.equal(2)
			expect(testTrack.Keyframes[2]).to.equal(3)
		end)
	end)

	describe("ScaleSelectedKeyframes", function()
		it("should scale the selected keyframes", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 3, true))
			store:dispatch(ScaleSelectedKeyframes(0, 2))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(3)
			expect(testTrack.Keyframes[3]).to.equal(6)
		end)

		it("should scale relative to the pivot", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 3, true))
			store:dispatch(ScaleSelectedKeyframes(2, 2))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(3)
			expect(testTrack.Keyframes[1]).to.equal(0)
			expect(testTrack.Keyframes[2]).to.equal(2)
			expect(testTrack.Keyframes[3]).to.equal(4)
		end)

		it("should not clobber keyframes when scaling up", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 3, true))
			store:dispatch(ScaleSelectedKeyframes(0, 2))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(3)
			expect(testTrack.Keyframes[1]).to.equal(2)
			expect(testTrack.Keyframes[2]).to.equal(4)
			expect(testTrack.Keyframes[3]).to.equal(6)

			store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 3, true))
			store:dispatch(ScaleSelectedKeyframes(3, 2))

			animationData = store:getState().AnimationData
			testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(3)
			expect(testTrack.Keyframes[1]).to.equal(0)
			expect(testTrack.Keyframes[2]).to.equal(1)
			expect(testTrack.Keyframes[3]).to.equal(3)
		end)

		it("should not clobber keyframes when scaling down", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "OtherTrack", 4, true))
			store:dispatch(SelectKeyframe("Root", "OtherTrack", 6, true))
			store:dispatch(SelectKeyframe("Root", "OtherTrack", 8, true))
			store:dispatch(ScaleSelectedKeyframes(8, 0.5))

			local animationData = store:getState().AnimationData
			local otherTrack = animationData.Instances.Root.Tracks.OtherTrack
			expect(#otherTrack.Keyframes).to.equal(4)
			expect(otherTrack.Keyframes[1]).to.equal(1)
			expect(otherTrack.Keyframes[2]).to.equal(6)
			expect(otherTrack.Keyframes[3]).to.equal(7)
			expect(otherTrack.Keyframes[4]).to.equal(8)

			store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "OtherTrack", 4, true))
			store:dispatch(SelectKeyframe("Root", "OtherTrack", 6, true))
			store:dispatch(SelectKeyframe("Root", "OtherTrack", 8, true))
			store:dispatch(ScaleSelectedKeyframes(4, 0.5))

			animationData = store:getState().AnimationData
			otherTrack = animationData.Instances.Root.Tracks.OtherTrack
			expect(#otherTrack.Keyframes).to.equal(4)
			expect(otherTrack.Keyframes[1]).to.equal(1)
			expect(otherTrack.Keyframes[2]).to.equal(4)
			expect(otherTrack.Keyframes[3]).to.equal(5)
			expect(otherTrack.Keyframes[4]).to.equal(6)
		end)

		it("should clobber existing keyframes that are overlapped", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(ScaleSelectedKeyframes(0, 2))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(2)
			expect(testTrack.Keyframes[1]).to.equal(2)
			expect(testTrack.Keyframes[2]).to.equal(3)
		end)

		it("should not place a keyframe between frames", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(ScaleSelectedKeyframes(0, 1.5))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(2)
			expect(testTrack.Keyframes[1]).to.equal(2)
			expect(testTrack.Keyframes[2]).to.equal(3)
		end)

		it("should do nothing if scale is 1", function()
			local store = createTestStore()
			store:dispatch(SelectKeyframe("Root", "TestTrack", 1, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 2, true))
			store:dispatch(SelectKeyframe("Root", "TestTrack", 3, true))
			store:dispatch(ScaleSelectedKeyframes(0, 1))

			local animationData = store:getState().AnimationData
			local testTrack = animationData.Instances.Root.Tracks.TestTrack
			expect(#testTrack.Keyframes).to.equal(3)
			expect(testTrack.Keyframes[1]).to.equal(1)
			expect(testTrack.Keyframes[2]).to.equal(2)
			expect(testTrack.Keyframes[3]).to.equal(3)
		end)
	end)

	describe("SelectEvent", function()
		it("should be able to select events", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1))
			local selectedEvents = store:getState().Status.SelectedEvents
			expect(selectedEvents[1]).to.be.ok()
		end)

		it("should clobber previous selection if multiSelect is false", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1))
			store:dispatch(SelectEvent(2))
			local selectedEvents = store:getState().Status.SelectedEvents
			expect(selectedEvents[1]).never.to.be.ok()
			expect(selectedEvents[2]).to.be.ok()
		end)

		it("should add to previous selection if multiSelect is true", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1, true))
			store:dispatch(SelectEvent(2, true))
			local selectedEvents = store:getState().Status.SelectedEvents
			expect(selectedEvents[1]).to.be.ok()
			expect(selectedEvents[2]).to.be.ok()
		end)
	end)

	describe("DeselectEvent", function()
		it("should be able to deselect events", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1, true))
			store:dispatch(SelectEvent(2, true))
			store:dispatch(DeselectEvent(2))
			local selectedEvents = store:getState().Status.SelectedEvents
			expect(selectedEvents[1]).to.be.ok()
			expect(selectedEvents[2]).never.to.be.ok()
		end)
	end)

	describe("CopySelectedEvents", function()
		it("should copy selected events to the clipboard", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1, true))
			store:dispatch(SelectEvent(2, true))
			store:dispatch(CopySelectedEvents())
			local clipboard = store:getState().Status.Clipboard
			expect(clipboard[1]).to.be.ok()
			expect(clipboard[1].TestEvent).to.equal("TestValue")
			expect(clipboard[2]).to.be.ok()
			expect(clipboard[2].TestEvent).to.equal("OtherValue")
			expect(clipboard[2].OtherEvent).to.equal("TestValue")
		end)
	end)

	describe("PasteEvents", function()
		it("should paste the copied events at the frame", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1, true))
			store:dispatch(SelectEvent(2, true))
			store:dispatch(CopySelectedEvents())
			store:dispatch(PasteEvents(4))
			local events = store:getState().AnimationData.Events
			expect(#events.Keyframes).to.equal(5)
			expect(events.Data[4]).to.be.ok()
			expect(events.Data[5]).to.be.ok()
			expect(events.Data[4].TestEvent).to.equal("TestValue")
			expect(events.Data[5].TestEvent).to.equal("OtherValue")
			expect(events.Data[5].OtherEvent).to.equal("TestValue")
		end)

		it("should clobber old events if pasted over", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1))
			store:dispatch(CopySelectedEvents())
			store:dispatch(PasteEvents(3))
			local events = store:getState().AnimationData.Events
			expect(#events.Keyframes).to.equal(3)
			expect(events.Data[3]).to.be.ok()
			expect(events.Data[3].TestEvent).to.equal("TestValue")
			expect(events.Data[3].OtherEvent).never.to.be.ok()
			expect(events.Data[3].FinalEvent).never.to.be.ok()
		end)
	end)

	describe("MoveSelectedEvents", function()
		it("should move the selected events", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1, true))
			store:dispatch(SelectEvent(2, true))
			store:dispatch(MoveSelectedEvents(1, 4))
			local events = store:getState().AnimationData.Events
			expect(#events.Keyframes).to.equal(3)
			expect(events.Data[1]).never.to.be.ok()
			expect(events.Data[2]).never.to.be.ok()
			expect(events.Data[4]).to.be.ok()
			expect(events.Data[4].TestEvent).to.equal("TestValue")
			expect(events.Data[5]).to.be.ok()
			expect(events.Data[5].TestEvent).to.equal("OtherValue")
			expect(events.Data[5].OtherEvent).to.equal("TestValue")
		end)

		it("should clobber old events if moved over", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1))
			store:dispatch(MoveSelectedEvents(1, 3))
			local events = store:getState().AnimationData.Events
			expect(#events.Keyframes).to.equal(2)
			expect(events.Data[1]).never.to.be.ok()
			expect(events.Data[3]).to.be.ok()
			expect(events.Data[3].TestEvent).to.equal("TestValue")
			expect(events.Data[3].OtherEvent).never.to.be.ok()
			expect(events.Data[3].FinalEvent).never.to.be.ok()
		end)

		it("should not clobber events when moving a group right", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1))
			store:dispatch(SelectEvent(2, true))
			store:dispatch(SelectEvent(3, true))
			store:dispatch(MoveSelectedEvents(1, 2))
			local events = store:getState().AnimationData.Events
			expect(#events.Keyframes).to.equal(3)
			expect(events.Data[2]).to.be.ok()
			expect(events.Data[3]).to.be.ok()
			expect(events.Data[4]).to.be.ok()
		end)

		it("should not clobber events when moving a group left", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1))
			store:dispatch(SelectEvent(2, true))
			store:dispatch(SelectEvent(3, true))
			store:dispatch(MoveSelectedEvents(1, 0))
			local events = store:getState().AnimationData.Events
			expect(#events.Keyframes).to.equal(3)
			expect(events.Data[0]).to.be.ok()
			expect(events.Data[1]).to.be.ok()
			expect(events.Data[2]).to.be.ok()
		end)
	end)

	describe("DeleteSelectedEvents", function()
		it("should delete the selected events", function()
			local store = createTestStore()
			store:dispatch(SelectEvent(1, true))
			store:dispatch(SelectEvent(2, true))
			store:dispatch(DeleteSelectedEvents())
			local events = store:getState().AnimationData.Events
			expect(#events.Keyframes).to.equal(1)
			expect(events.Data[1]).never.to.be.ok()
			expect(events.Data[2]).never.to.be.ok()
			expect(events.Data[3]).to.be.ok()
		end)
	end)

	describe("SetEvents", function()
		it("should replace the Events table in the animation data", function()
			local store = createTestStore()
			store:dispatch(SetEvents({
				Keyframes = {1},
				Data = {
					[1] = {
						TestEvent2 = "TestValue2",
					},
				},
			}))
			local events = store:getState().AnimationData.Events
			expect(#events.Keyframes).to.equal(1)
			expect(events.Data[1]).to.be.ok()
			expect(events.Data[1].TestEvent).never.to.be.ok()
			expect(events.Data[1].TestEvent2).to.equal("TestValue2")
			expect(events.Data[2]).never.to.be.ok()
			expect(events.Data[3]).never.to.be.ok()
		end)
	end)

	describe("SnapToNearestKeyframe", function()
		it("playhead should go to closest keyframe within threshold", function()
			local store = createTestStore()
			store:dispatch(SetEditingLength(10))
			store:dispatch(SetSnapToKeys(true))

			local instance = Instance.new("Model")
			instance.Name = "Test"
			store:dispatch(SetRootInstance(instance))
			store:dispatch(SnapToNearestKeyframe(9, 100))
			local state = store:getState()
			expect(state.Status.Playhead).to.equal(8)
		end)
	end)

	describe("ToggleSnapToKeys", function()
		it("should toggle SnapToKeys", function()
			local store = createTestStore()
			store:dispatch(SetSnapToKeys(true))
			store:dispatch(ToggleSnapToKeys())
			local state = store:getState()
			expect(state.Status.SnapToKeys).to.equal(false)
			store:dispatch(ToggleSnapToKeys())
			state = store:getState()
			expect(state.Status.SnapToKeys).to.equal(true)
		end)
	end)

	describe("RenameKeyframe", function()
		it("should set the name of a summary keyframe", function()
			local store = createTestStore()
			store:dispatch(RenameKeyframe(1, "TestName"))
			local animationData = store:getState().AnimationData
			local names = animationData.Events.NamedKeyframes

			expect(names).to.be.ok()
			expect(names[1]).to.equal("TestName")
		end)

		it("should clear the name of a summary keyframe", function()
			local store = createTestStore()
			store:dispatch(RenameKeyframe(1, "TestName"))
			store:dispatch(RenameKeyframe(1, nil))
			local animationData = store:getState().AnimationData
			local names = animationData.Events.NamedKeyframes

			expect(names).to.be.ok()
			expect(names[1]).never.to.be.ok()
		end)

		it("should clear the name of a summary keyframe if it is the default name", function()
			local store = createTestStore()
			store:dispatch(RenameKeyframe(1, "TestName"))
			store:dispatch(RenameKeyframe(1, Constants.DEFAULT_KEYFRAME_NAME))
			local animationData = store:getState().AnimationData
			local names = animationData.Events.NamedKeyframes

			expect(names).to.be.ok()
			expect(names[1]).never.to.be.ok()
		end)
	end)

	describe("SkipAnimation", function()
		it("should skip the playhead to the previous summary keyframe", function()
			local store = createTestStore()
			store:dispatch(AddTrack("Root", "TestTrack"))
			store:dispatch(AddTrack("Root", "OtherTrack"))
			store:dispatch(SetPlayhead(3))
			store:dispatch(SetRootInstance({}))
			store:dispatch(SkipAnimation(false))
			expect(store:getState().Status.Playhead).to.equal(2)
			store:dispatch(SkipAnimation(false))
			expect(store:getState().Status.Playhead).to.equal(1)
			store:dispatch(SkipAnimation(false))
			expect(store:getState().Status.Playhead).to.equal(0)
		end)

		it("should skip the playhead to the next summary keyframe", function()
			local store = createTestStore()
			store:dispatch(AddTrack("Root", "TestTrack"))
			store:dispatch(AddTrack("Root", "OtherTrack"))
			store:dispatch(SetPlayhead(3))
			store:dispatch(SetRootInstance({}))
			store:dispatch(SkipAnimation(true))
			expect(store:getState().Status.Playhead).to.equal(4)
			store:dispatch(SkipAnimation(true))
			expect(store:getState().Status.Playhead).to.equal(6)
			store:dispatch(SkipAnimation(true))
			expect(store:getState().Status.Playhead).to.equal(8)
		end)
	end)

	describe("UpdateEditingLength", function()
		it("should set the editing length", function()
			local store = createTestStore()
			store:dispatch(UpdateEditingLength(60))
			expect(store:getState().Status.EditingLength).to.equal(60)
		end)

		it("should max the length with the min length and animation length", function()
			local store = createTestStore()
			store:dispatch(UpdateEditingLength(2))
			expect(store:getState().Status.EditingLength).to.equal(Constants.DEFAULT_FRAMERATE)
		end)
	end)

	describe("SetAnalytics", function()
		it("should set the Analytics implementation", function()
			local store = createTestStore()
			store:dispatch(SetAnalytics("NewTestAnalytics"))
			expect(store:getState().Analytics).to.equal("NewTestAnalytics")
		end)
	end)
end