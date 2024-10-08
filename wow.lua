local bitlib = require('bit')

local UNIMPLEMENTED = function() end

local unpack = unpack or table.unpack

local function Mixin(obj, ...)
  for _, t in ipairs({ ... }) do
    for k, v in pairs(t) do
      obj[k] = v
    end
  end
  return obj
end

local function RunScript(widget, name, ...)
  local script = widget.scripts[name]
  if script then
    script.handler(widget, ...)
    for _, hook in ipairs(script.hooks) do
      hook(widget, ...)
    end
  end
end

local unitClasses = {
  { 'Warrior', 'WARRIOR' },
  { 'Paladin', 'PALADIN' },
  { 'Hunter', 'HUNTER' },
  { 'Rogue', 'ROGUE' },
  { 'Priest', 'PRIEST' },
  {},
  { 'Shaman', 'SHAMAN' },
  { 'Mage', 'MAGE' },
  { 'Warlock', 'WARLOCK' },
  {},
  { 'Druid', 'DRUID' },
}

local function CreateFrameImpl(env, state, className, frameName, parent, templates)
  local CreateFrame = function(...)
    return CreateFrameImpl(env, state, ...)
  end
  local hierarchy = {
    Alpha = {
      inherits = { 'Animation' },
      api = {
        SetFromAlpha = UNIMPLEMENTED,
        SetToAlpha = UNIMPLEMENTED,
      },
    },
    Animation = {
      inherits = { 'ScriptObject', 'UIObject' },
      api = {
        SetDuration = UNIMPLEMENTED,
        SetOrder = UNIMPLEMENTED,
        SetStartDelay = UNIMPLEMENTED,
      },
    },
    AnimationGroup = {
      inherits = { 'Region', 'ScriptObject' },
      api = {
        CreateAnimation = function(self, animType)
          return CreateFrame(animType, nil, self)
        end,
        SetToFinalAlpha = UNIMPLEMENTED,
        Stop = UNIMPLEMENTED,
      },
    },
    Button = {
      inherits = { 'Frame' },
      scripts = { 'PreClick', 'OnClick', 'PostClick' },
      api = {
        Click = function(self, ...)
          RunScript(self, 'PreClick', ...)
          RunScript(self, 'OnClick', ...)
          RunScript(self, 'PostClick', ...)
        end,
        Disable = UNIMPLEMENTED,
        Enable = UNIMPLEMENTED,
        GetHighlightTexture = function(self)
          return self.highlightTexture
        end,
        GetNormalTexture = function(self)
          return self.NormalTexture
        end,
        GetPushedTexture = function(self)
          return self.pushedTexture
        end,
        RegisterForClicks = UNIMPLEMENTED,
        SetEnabled = UNIMPLEMENTED,
        SetHighlightFontObject = UNIMPLEMENTED,
        SetHighlightTexture = function(self)
          self.highlightTexture = self:CreateTexture()
        end,
        SetMotionScriptsWhileDisabled = UNIMPLEMENTED,
        SetNormalFontObject = UNIMPLEMENTED,
        SetNormalTexture = function(self)
          self.NormalTexture = self:CreateTexture()
        end,
        SetPushedTexture = function(self)
          self.pushedTexture = self:CreateTexture()
        end,
        SetText = UNIMPLEMENTED,
      },
    },
    CheckButton = {
      inherits = { 'Button' },
      api = {
        SetChecked = UNIMPLEMENTED,
      },
    },
    Cooldown = {
      inherits = { 'Frame' },
      api = {
        SetDrawBling = UNIMPLEMENTED,
        SetReverse = UNIMPLEMENTED,
        SetSwipeColor = UNIMPLEMENTED,
      },
    },
    FontInstance = {
      data = {
        fontObject = {},
      },
      api = {
        GetFont = UNIMPLEMENTED,
        GetFontObject = function(self)
          return self.fontObject
        end,
        GetTextColor = UNIMPLEMENTED,
        SetFont = UNIMPLEMENTED,
        SetFontObject = function(self, fontObject)
          self.fontObject = fontObject
        end,
        SetJustifyH = UNIMPLEMENTED,
        SetJustifyV = UNIMPLEMENTED,
        SetTextColor = UNIMPLEMENTED,
      },
    },
    FontString = {
      inherits = { 'FontInstance', 'LayeredRegion' },
      api = {
        GetText = function(self)
          return self.fontStringText
        end,
        SetText = function(self, str)
          self.fontStringText = str
        end,
      },
    },
    Frame = {
      inherits = { 'Region', 'ScriptObject' },
      data = {
        attributes = {},
        registeredEvents = {},
      },
      scripts = { 'OnEvent', 'OnUpdate' },
      api = {
        CreateFontString = function(self)
          return CreateFrame('FontString', nil, self)
        end,
        CreateTexture = function(self)
          return CreateFrame('Texture', nil, self)
        end,
        EnableMouse = UNIMPLEMENTED,
        EnableMouseWheel = UNIMPLEMENTED,
        GetAttribute = function(self, name)
          return self.attributes[name]
        end,
        GetID = function(self)
          return self.frameID or 0
        end,
        RegisterEvent = function(self, ev)
          self.registeredEvents[ev] = true
        end,
        RegisterForDrag = UNIMPLEMENTED,
        RegisterUnitEvent = UNIMPLEMENTED,
        SetAttribute = function(self, name, value)
          self.attributes[name] = value
        end,
        SetBackdrop = UNIMPLEMENTED,
        SetBackdropBorderColor = UNIMPLEMENTED,
        SetBackdropColor = UNIMPLEMENTED,
        SetClampedToScreen = UNIMPLEMENTED,
        SetClampRectInsets = UNIMPLEMENTED,
        SetFixedFrameLevel = UNIMPLEMENTED,
        SetFixedFrameStrata = UNIMPLEMENTED,
        SetFrameLevel = UNIMPLEMENTED,
        SetFrameStrata = UNIMPLEMENTED,
        SetID = function(self, id)
          self.frameID = id
        end,
        SetMinResize = UNIMPLEMENTED,
        SetMouseClickEnabled = UNIMPLEMENTED,
        SetMovable = UNIMPLEMENTED,
        SetResizable = UNIMPLEMENTED,
        SetToplevel = UNIMPLEMENTED,
        SetUserPlaced = UNIMPLEMENTED,
        UnregisterAllEvents = UNIMPLEMENTED,
        UnregisterEvent = UNIMPLEMENTED,
      },
    },
    GameTooltip = {
      inherits = { 'Frame' },
      data = {
        lines = {},
      },
      scripts = { 'OnTooltipSetItem', 'OnTooltipSetSpell', 'OnTooltipSetUnit' },
      api = {
        AddDoubleLine = function(self, l, r, lr, lg, lb, rr, rg, rb)
          table.insert(self.lines, {
            l = l,
            r = r,
            lr = lr,
            lg = lg,
            lb = lb,
            rr = rr,
            rg = rg,
            rb = rb,
          })
        end,
        AddFontStrings = UNIMPLEMENTED,
        AddLine = function(self, s, r, g, b)
          self:AddDoubleLine(s, nil, r, g, b, nil, nil, nil)
        end,
        ClearLines = function(self)
          self.lines = {}
        end,
        GetItem = function(self)
          return self.item
        end,
        GetOwner = UNIMPLEMENTED,
        GetSpell = function(self)
          return self.spell
        end,
        GetUnit = function(self)
          return 'bogusUnitName', self.unit
        end,
        IsOwned = UNIMPLEMENTED,
        NumLines = function(self)
          return #self.lines
        end,
        SetInventoryItem = UNIMPLEMENTED,
        SetItem = function(self, item)
          self.item = item
          RunScript(self, 'OnTooltipSetItem')
        end,
        SetOwner = UNIMPLEMENTED,
        SetSpell = function(self, spell)
          self.spell = spell
          RunScript(self, 'OnTooltipSetSpell')
        end,
        SetUnit = function(self, unit)
          self.unit = unit
          RunScript(self, 'OnTooltipSetUnit')
        end,
      },
    },
    LayeredRegion = {
      inherits = { 'Region' },
      api = {
        SetVertexColor = UNIMPLEMENTED,
      },
    },
    MessageFrame = {
      inherits = { 'Frame', 'FontInstance' },
    },
    Minimap = {
      inherits = { 'Frame' },
      api = {
        SetMaskTexture = UNIMPLEMENTED,
        SetZoom = UNIMPLEMENTED,
      },
    },
    Region = {
      inherits = { 'UIObject', 'ScriptObject' },
      data = {
        alpha = 1.0,
        shown = true,
      },
      api = {
        ClearAllPoints = UNIMPLEMENTED,
        CreateAnimationGroup = function(self)
          return CreateFrame('AnimationGroup', nil, self)
        end,
        GetAlpha = function(self)
          return self.alpha
        end,
        GetCenter = UNIMPLEMENTED,
        GetEffectiveAlpha = function()
          return 1.0
        end,
        GetHeight = function(self)
          return self.height or 10
        end,
        GetWidth = UNIMPLEMENTED,
        Hide = function(self, ...)
          self.shown = false
          RunScript(self, 'OnHide', ...)
        end,
        IsShown = function(self)
          return self.shown
        end,
        IsVisible = UNIMPLEMENTED,
        SetAllPoints = UNIMPLEMENTED,
        SetAlpha = function(self, value)
          self.alpha = value
        end,
        SetHeight = function(self, value)
          self.height = value
        end,
        SetParent = UNIMPLEMENTED,
        SetPoint = UNIMPLEMENTED,
        SetScale = UNIMPLEMENTED,
        SetShown = function(self, value)
          if value then
            self:Show()
          else
            self:Hide()
          end
        end,
        SetSize = UNIMPLEMENTED,
        SetWidth = UNIMPLEMENTED,
        Show = function(self, ...)
          self.shown = true
          RunScript(self, 'OnShow', ...)
        end,
      },
    },
    ScriptObject = {
      data = {
        scripts = {},
      },
      api = {
        GetScript = function(self, name)
          local script = self.scripts[name]
          return script and script.handler or nil
        end,
        HookScript = function(self, name, hook)
          local script = self.scripts[name]
          if not script then
            return false
          end
          table.insert(script.hooks, hook)
          return true
        end,
        SetScript = function(self, name, handler)
          self.scripts[name] = {
            handler = handler,
            hooks = {},
          }
        end,
      },
    },
    ScrollFrame = {
      inherits = { 'Frame' },
      api = {
        SetScrollChild = UNIMPLEMENTED,
      },
    },
    Slider = {
      inherits = { 'Frame' },
      api = {
        SetMinMaxValues = UNIMPLEMENTED,
        SetValue = UNIMPLEMENTED,
        SetValueStep = UNIMPLEMENTED,
      },
    },
    StatusBar = {
      inherits = { 'Frame' },
      api = {
        SetMinMaxValues = UNIMPLEMENTED,
        SetStatusBarColor = UNIMPLEMENTED,
        SetStatusBarTexture = UNIMPLEMENTED,
        SetValue = UNIMPLEMENTED,
      },
    },
    Texture = {
      inherits = { 'LayeredRegion' },
      api = {
        GetTexture = UNIMPLEMENTED,
        GetVertexColor = UNIMPLEMENTED,
        SetBlendMode = UNIMPLEMENTED,
        SetColorTexture = UNIMPLEMENTED,
        SetDesaturated = UNIMPLEMENTED,
        SetTexCoord = UNIMPLEMENTED,
        SetTexture = UNIMPLEMENTED,
      },
    },
    UIObject = {
      api = {
        GetName = function(self)
          return self._name
        end,
        GetParent = function(self)
          return self.parent
        end,
        -- TODO move this to ParentedObject
        IsForbidden = UNIMPLEMENTED,
      },
    },
  }
  local mixins
  mixins = {
    ActionButtonTemplate = function()
      return {
        AutoCastable = CreateFrame('Texture'),
        AutoCastShine = CreateFrame('Frame'),
        Border = CreateFrame('Texture'),
        cooldown = CreateFrame('Cooldown'),
        Count = CreateFrame('FontString'),
        Flash = CreateFrame('Texture'),
        FlyoutArrow = CreateFrame('Frame'),
        FlyoutBorder = CreateFrame('Frame'),
        FlyoutBorderShadow = CreateFrame('Frame'),
        HotKey = CreateFrame('FontString'),
        icon = CreateFrame('Texture'),
        Name = CreateFrame('FontString'),
        SpellHighlightAnim = CreateFrame('AnimationGroup'),
        SpellHighlightTexture = CreateFrame('Texture'),
      }
    end,
    CooldownFrameTemplate = UNIMPLEMENTED,
    GameTooltipTemplate = UNIMPLEMENTED,
    OptionsButtonTemplate = function(self)
      return {
        Text = CreateFrame('FontString', self:GetName() .. 'Text'),
      }
    end,
    OptionsCheckButtonTemplate = function(self)
      return {
        Text = CreateFrame('FontString', self:GetName() .. 'Text'),
      }
    end,
    SecureActionButtonTemplate = function()
      return {
        OnClick = function(self)
          local ty = self:GetAttribute('type')
          if ty == 'macro' then
            table.insert(state.commands, {
              macro = self:GetAttribute('macrotext'),
            })
          elseif ty == 'spell' then
            table.insert(state.commands, {
              spell = self:GetAttribute('spell'),
              unit = self:GetAttribute('unit'),
            })
          end
        end,
      }
    end,
    SecureHandlerBaseTemplate = function(self)
      -- TODO inheritance
      return mixins.SecureHandlerStateTemplate(self)
    end,
    SecureHandlerStateTemplate = function(self)
      local renv
      local function wrap(frame)
        local refs = {}
        return {
          CallMethod = function(_, method, ...)
            return frame[method](frame, ...)
          end,
          ClearBindings = UNIMPLEMENTED,
          GetAttribute = function(_, attr)
            return frame:GetAttribute(attr)
          end,
          GetFrameRef = function(_, name)
            return refs[name]
          end,
          GetID = function()
            return frame:GetID()
          end,
          GetName = function()
            return frame:GetName()
          end,
          Hide = function()
            frame:Hide()
          end,
          Run = function(wself, cmd, ...)
            return wself:RunFor(wself, cmd, ...)
          end,
          RunAttribute = function(wself, attr, ...)
            wself:Run(wself:GetAttribute(attr), ...)
          end,
          RunFor = function(_, wother, cmd, ...)
            renv.self = wother
            return setfenv(loadstring(cmd), renv)(...)
          end,
          SetAttribute = function(_, attr, value)
            return frame:SetAttribute(attr, value)
          end,
          SetBindingClick = UNIMPLEMENTED,
          SetFrameRef = function(_, name, ref)
            refs[name] = ref
          end,
          Show = function()
            frame:Show()
          end,
        }
      end
      local wself = wrap(self)
      renv = {
        control = wself,
        ipairs = ipairs,
        newtable = function()
          return {}
        end,
        owner = wself,
        pairs = pairs,
        self = wself,
        tinsert = table.insert,
        tonumber = tonumber,
        tostring = tostring,
        type = type,
      }
      return {
        Execute = function(_, cmd)
          assert(not env.InCombatLockdown(), 'disallowed in combat')
          wself:Run(cmd)
        end,
        SetFrameRef = function(_, name, frame)
          assert(not env.InCombatLockdown(), 'disallowed in combat')
          wself:SetFrameRef(name, wrap(frame))
        end,
        WrapScript = function(_, frame, script, pre, post)
          assert(not env.InCombatLockdown(), 'disallowed in combat')
          local old = frame:GetScript(script)
          frame:SetScript(script, function(fself, ...)
            local fwrap = wrap(fself)
            local _, arg = fwrap:Run(pre)
            old(fself, ...)
            if arg then
              fwrap:Run(post, arg)
            end
          end)
        end,
      }
    end,
    SecureUnitButtonTemplate = UNIMPLEMENTED,
    SharedTooltipTemplate = UNIMPLEMENTED,
    UIPanelButtonTemplate = function(self)
      return {
        Text = CreateFrame('FontString', self:GetName() .. 'Text'),
      }
    end,
  }
  local toProcess = { className }
  local classes = {}
  while #toProcess > 0 do
    local p = table.remove(toProcess)
    assert(hierarchy[p] ~= nil, 'unknown class ' .. p)
    classes[p] = hierarchy[p]
    for _, c in ipairs(hierarchy[p].inherits or {}) do
      table.insert(toProcess, c)
    end
  end
  local frame = {}
  local scripts = {}
  for _, class in pairs(classes) do
    Mixin(frame, class.api or {})
    Mixin(frame, class.data or {})
    for _, v in ipairs(class.scripts or {}) do
      table.insert(scripts, v)
    end
  end
  frame.parent = parent
  frame._name = frameName
  frame._type = className
  for _, v in ipairs(scripts) do
    frame:SetScript(v, function() end)
  end
  for t in string.gmatch(templates or '', '[^, ]+') do
    assert(mixins[t] ~= nil, 'unknown mixin ' .. t)
    for k, v in pairs(mixins[t](frame) or {}) do
      if k == 'OnClick' then
        frame:SetScript(k, v)
      else
        frame[k] = v
      end
    end
  end
  if classes['Frame'] then
    table.insert(state.frames, frame)
  end
  if frameName then
    env[frameName] = frame
    state.frames[frameName] = frame
  end
  return frame
end

return function()
  local env = {}
  local state
  local CreateFrame = function(...)
    return CreateFrameImpl(env, state, ...)
  end
  state = {
    actions = {},
    bindings = {},
    commands = {},
    frames = {},
    petactions = {},
    player = {
      class = 2,
      health = 1500,
      healthmax = 2000,
      level = 42,
      name = 'Kewhand',
      power = 1000,
      powermax = 1250,
      race = 'Human',
    },
    realm = 'Realm',
    tickers = {},
    cvars = {},
    sentChats = {},
    consoleKey = nil,
    inCombat = false,
    inGroup = false,
    isMounted = false,
    knownSpells = {},
    inventory = {},
    equipment = {},
    nameplates = {},
    crafts = {},
    buffs = {},
    talents = {},
    localTime = 10000,
    serverTime = 10000000,
    printed = '',
    SendEvent = function(self, ev, ...)
      for _, f in ipairs(self.frames) do
        if f.registeredEvents[ev] then
          RunScript(f, 'OnEvent', ev, ...)
        end
      end
    end,
    TickUpdate = function(self, delay)
      self.localTime = self.localTime + delay
      for _, f in ipairs(self.frames) do
        RunScript(f, 'OnUpdate', delay)
      end
    end,
    CreateNamePlate = function(self)
      local np = {
        UnitFrame = {
          healthBar = CreateFrame('Frame'),
        },
      }
      table.insert(self.nameplates, { np = np, used = false })
      self:SendEvent('NAME_PLATE_CREATED', np)
    end,
    AddNamePlate = function(self)
      local index = nil
      for i, d in ipairs(self.nameplates) do
        if not d.used then
          index = i
          break
        end
      end
      if not index then
        self:CreateNamePlate()
        index = #self.nameplates
      end
      self.nameplates[index].used = true
      local name = 'nameplate' .. index
      self:SendEvent('NAME_PLATE_UNIT_ADDED', name)
      return name
    end,
    RemoveNamePlate = function(self, token)
      if token:sub(1, 9) == 'nameplate' then
        local index = tonumber(token:sub(10))
        self.nameplates[index].used = false
        self:SendEvent('NAME_PLATE_UNIT_REMOVED', token)
      end
    end,
    IsSpellKnown = function(self, spell)
      for _, s in ipairs(self.knownSpells) do
        if s == spell then
          return true
        end
      end
      return false
    end,
    EnterCombat = function(self)
      self:SendEvent('PLAYER_REGEN_DISABLED')
      self.inCombat = true
    end,
    LeaveCombat = function(self)
      self.inCombat = false
      self:SendEvent('PLAYER_REGEN_ENABLED')
    end,
  }
  local wowapi = {
    ANCHOR_BOTTOMLEFT = 'ANCHOR_BOTTOMLEFT',
    ANCHOR_NONE = 'ANCHOR_NONE',
    ATTACK_BUTTON_FLASH_TIME = 0.1,
    AuraUtil = {
      FindAura = UNIMPLEMENTED,
      FindAuraByName = UNIMPLEMENTED,
    },
    AutoCastShine_AutoCastStart = UNIMPLEMENTED,
    AutoCastShine_AutoCastStop = UNIMPLEMENTED,
    BACKPACK_CONTAINER = 0,
    BANK_CONTAINER = -1,
    BASE_MOVEMENT_SPEED = 7,
    bit = {
      band = bitlib.band,
      bor = bitlib.bor,
    },
    BuffFrame = CreateFrame('Frame'),
    C_ChatInfo = {
      RegisterAddonMessagePrefix = UNIMPLEMENTED,
      SendAddonMessage = function(prefix, message, chatType, target)
        table.insert(state.sentChats, {
          prefix = prefix,
          message = message,
          chatType = chatType,
          target = target,
        })
      end,
    },
    C_Container = {
      GetContainerItemLink = UNIMPLEMENTED,
      GetContainerNumSlots = function()
        return 4
      end,
      GetItemCooldown = function()
        return 0, 0, 0
      end,
    },
    C_Item = {
      RequestLoadItemDataByID = function(item)
        state:SendEvent('ITEM_DATA_LOAD_RESULT', item, true)
      end,
    },
    C_Map = {
      GetBestMapForUnit = UNIMPLEMENTED,
      GetMapInfo = function(mapid)
        return { name = 'o' .. mapid }
      end,
      GetPlayerMapPosition = function()
        return { x = 0.12, y = 0.34 }
      end,
    },
    C_NamePlate = {
      GetNamePlateForUnit = function(unit)
        if unit:sub(1, 9) == 'nameplate' then
          local t = state.nameplates[tonumber(unit:sub(10))]
          return t and t.np
        end
      end,
    },
    C_Timer = {
      After = UNIMPLEMENTED,
      NewTicker = function(interval, func)
        table.insert(state.tickers, {
          interval = interval,
          func = func,
        })
      end,
      NewTimer = UNIMPLEMENTED,
    },
    CastingBarFrame = CreateFrame('StatusBar'),
    ChatFrame1 = CreateFrame('MessageFrame'),
    COMBAT_TEXT_SCROLL_FUNCTION = UNIMPLEMENTED,
    CombatText_AddMessage = UNIMPLEMENTED,
    CompactRaidFrameManager = CreateFrame('Frame'),
    CooldownFrame_Set = UNIMPLEMENTED,
    CreateFrame = CreateFrame,
    DebuffTypeColor = {},
    DevTools_Dump = UNIMPLEMENTED,
    DisableAddOn = UNIMPLEMENTED,
    DoEmote = UNIMPLEMENTED,
    Enum = {
      PowerType = {},
      PvPUnitClassification = {},
      SummonStatus = {},
    },
    EquipItemByName = function(item, slot)
      state.equipment[slot] = item
    end,
    ERR_LEARN_SPELL_S = 'You have learned a new spell: %s.',
    FACTION_BAR_COLORS = {},
    FindSpellBookSlotBySpellID = UNIMPLEMENTED,
    FocusFrame = CreateFrame('Frame'),
    FollowUnit = UNIMPLEMENTED,
    format = string.format,
    GameTime_GetTime = function()
      return '1:23'
    end,
    GameTooltip = CreateFrame('GameTooltip', 'GameTooltip'),
    GameTooltip_SetDefaultAnchor = UNIMPLEMENTED,
    GameTooltipStatusBar = CreateFrame('StatusBar'),
    GameTooltipTextRight1 = CreateFrame('FontString'),
    GetActionCooldown = function()
      return 0, 0, 0
    end,
    GetActionCount = function()
      return 0
    end,
    GetActionInfo = UNIMPLEMENTED,
    GetActionText = UNIMPLEMENTED,
    GetActionTexture = UNIMPLEMENTED,
    GetAddOnEnableState = UNIMPLEMENTED,
    GetAddOnMetadata = UNIMPLEMENTED,
    GetBindingByKey = function(key)
      return state.bindings[key]
    end,
    GetBindingKey = UNIMPLEMENTED,
    GetBindingText = function()
      return ''
    end,
    GetBuildInfo = function()
      return '1.13.6', '55555', 'Jan 11 2021', 11306
    end,
    GetClassColor = UNIMPLEMENTED,
    GetCoinTextureString = function()
      return ''
    end,
    GetContainerItemInfo = UNIMPLEMENTED,
    GetContainerItemLink = UNIMPLEMENTED,
    GetContainerNumFreeSlots = function()
      return 2
    end,
    GetContainerNumSlots = function()
      return 4
    end,
    GetCraftInfo = function(index)
      return unpack(state.crafts[index])
    end,
    GetFramerate = function()
      return 100
    end,
    getglobal = function(k)
      return env[k]
    end,
    GetInstanceInfo = function()
      return nil, nil, nil, nil, nil, nil, nil, state.instanceId
    end,
    GetInventoryItemCooldown = function()
      return 0, 0, 0
    end,
    GetInventoryItemCount = UNIMPLEMENTED,
    GetInventoryItemDurability = UNIMPLEMENTED,
    GetInventoryItemID = UNIMPLEMENTED,
    GetInventoryItemLink = function(unit, i)
      assert(unit == 'player')
      return state.equipment[i]
    end,
    GetInventoryItemTexture = UNIMPLEMENTED,
    GetInventorySlotInfo = UNIMPLEMENTED,
    GetItemCooldown = function()
      return 0, 0, 0
    end,
    GetItemCount = function(item)
      return state.inventory[item] or 0
    end,
    GetItemIcon = UNIMPLEMENTED,
    GetItemInfo = function()
      return nil, nil, nil, nil, nil, nil, nil, 2
    end,
    GetItemSpell = UNIMPLEMENTED,
    GetLocale = UNIMPLEMENTED,
    GetMacroInfo = UNIMPLEMENTED,
    GetMaxPlayerLevel = function()
      return 60
    end,
    GetMoney = function()
      return 0
    end,
    GetMouseFoci = function()
      return {}
    end,
    GetMouseFocus = UNIMPLEMENTED,
    GetNumCrafts = function()
      return #state.crafts
    end,
    GetNumGroupMembers = function()
      return 0
    end,
    GetNumSkillLines = function()
      return 0
    end,
    GetNumTalents = function(tab)
      assert(tab >= 1 and tab <= #state.talents)
      return #state.talents[tab]
    end,
    GetNumTalentTabs = function()
      return #state.talents
    end,
    GetNumTrackingTypes = function()
      return 0
    end,
    GetPetActionCooldown = function()
      return 0, 0, 0
    end,
    GetPetActionInfo = function(num)
      return unpack(state.petactions[num] or {})
    end,
    GetPetHappiness = UNIMPLEMENTED,
    GetRealmName = function()
      return state.realm
    end,
    GetRealZoneText = function(instanceId)
      return 'i' .. instanceId
    end,
    GetServerTime = function()
      return state.serverTime
    end,
    GetShapeshiftForm = UNIMPLEMENTED,
    GetSkillLineInfo = UNIMPLEMENTED,
    GetSpellCharges = UNIMPLEMENTED,
    GetSpellCooldown = function()
      return 0, 0, 0
    end,
    GetSpellCount = function()
      return 0
    end,
    GetSpellInfo = function(spell)
      return 'spell' .. spell, nil, 12345, 0, 0, 0, 23456
    end,
    GetSpellLossOfControlCooldown = function()
      return 0, 0
    end,
    GetSpellSubtext = UNIMPLEMENTED,
    GetSpellTexture = UNIMPLEMENTED,
    GetSubZoneText = function()
      return 'subzone'
    end,
    GetTalentInfo = function(tab, i)
      assert(tab >= 1 and tab <= #state.talents)
      assert(i >= 1 and i <= #state.talents[tab])
      local c = state.talents[tab][i] or 0
      return nil, nil, nil, nil, c
    end,
    GetThreatStatusColor = UNIMPLEMENTED,
    GetTime = function()
      return state.localTime
    end,
    GetTrackingInfo = UNIMPLEMENTED,
    GetTrackingTexture = UNIMPLEMENTED,
    GetUnitSpeed = function()
      return 0
    end,
    GetWeaponEnchantInfo = UNIMPLEMENTED,
    GetXPExhaustion = UNIMPLEMENTED,
    GetZonePVPInfo = UNIMPLEMENTED,
    GetZoneText = function()
      return 'zone'
    end,
    HasAction = function(action)
      return not not state.actions[action]
    end,
    hooksecurefunc = UNIMPLEMENTED,
    InCombatLockdown = function()
      return state.inCombat
    end,
    InterfaceOptions_AddCategory = UNIMPLEMENTED,
    InterfaceOptionsFrame_OpenToCategory = UNIMPLEMENTED,
    IsActionInRange = UNIMPLEMENTED,
    IsAttackSpell = UNIMPLEMENTED,
    IsAutoRepeatAction = UNIMPLEMENTED,
    IsAutoRepeatSpell = UNIMPLEMENTED,
    IsConsumableAction = UNIMPLEMENTED,
    IsConsumableItem = function()
      return true
    end,
    IsConsumableSpell = UNIMPLEMENTED,
    IsCurrentAction = UNIMPLEMENTED,
    IsCurrentItem = UNIMPLEMENTED,
    IsCurrentSpell = UNIMPLEMENTED,
    IsEquippedAction = UNIMPLEMENTED,
    IsEquippedItem = UNIMPLEMENTED,
    IsInGroup = function()
      return state.inGroup
    end,
    IsInInstance = function()
      return state.instanceId ~= nil
    end,
    IsInRaid = UNIMPLEMENTED,
    IsItemAction = UNIMPLEMENTED,
    IsItemInRange = UNIMPLEMENTED,
    IsLoggedIn = UNIMPLEMENTED,
    IsMounted = function()
      return state.isMounted
    end,
    IsResting = UNIMPLEMENTED,
    IsShiftKeyDown = UNIMPLEMENTED,
    IsSpellInRange = UNIMPLEMENTED,
    IsSpellKnown = function(spell)
      return state:IsSpellKnown(spell)
    end,
    IsStackableAction = UNIMPLEMENTED,
    IsStealthed = UNIMPLEMENTED,
    IsUsableAction = UNIMPLEMENTED,
    IsUsableItem = UNIMPLEMENTED,
    IsUsableSpell = function(spell)
      return state:IsSpellKnown(spell), false
    end,
    ItemRefTooltip = CreateFrame('GameTooltip'),
    LoadAddOn = UNIMPLEMENTED,
    MainMenuBar = CreateFrame('Frame'),
    MAX_PARTY_MEMBERS = 4,
    MAX_RAID_MEMBERS = 40,
    Minimap = CreateFrame('Minimap'),
    MinimapBackdrop = CreateFrame('Frame'),
    MinimapCluster = CreateFrame('Frame'),
    MiniMapTracking = CreateFrame('Frame'),
    MiniMapTrackingFrame = CreateFrame('Frame'),
    MiniMapTrackingIcon = CreateFrame('Texture'),
    Mixin = Mixin,
    NumberFont_Small = CreateFrame('FontInstance'),
    NUM_BAG_SLOTS = 4,
    NUM_BANKBAGSLOTS = 6,
    NUM_PET_ACTION_SLOTS = 10,
    PartyMemberFrame1 = CreateFrame('Button'),
    PartyMemberFrame2 = CreateFrame('Button'),
    PartyMemberFrame3 = CreateFrame('Button'),
    PartyMemberFrame4 = CreateFrame('Button'),
    PlayerFrame = CreateFrame('Button'),
    PowerBarColor = { MANA = { r = 0.5, g = 0.5, b = 0.5 } },
    PROFESSIONS_FIRST_AID = 'First Aid',
    RaidFrame = CreateFrame('Frame'),
    RAID_CLASS_COLORS = {},
    RegisterAttributeDriver = UNIMPLEMENTED,
    RegisterStateDriver = UNIMPLEMENTED,
    RegisterUnitWatch = UNIMPLEMENTED,
    ReloadUI = UNIMPLEMENTED,
    SetBinding = function(key, command)
      state.bindings[key] = command
      return true
    end,
    SetBindingClick = function(key, buttonName)
      state.bindings[key] = 'CLICK ' .. buttonName
      return true
    end,
    SendChatMessage = function(message, chatType)
      table.insert(state.sentChats, {
        message = message,
        chatType = chatType,
      })
    end,
    SetConsoleKey = function(key)
      state.consoleKey = key
    end,
    SetCVar = function(key, value)
      state.cvars[key] = value
    end,
    SetDesaturation = function(texture, desaturation)
      texture:SetDesaturated(desaturation)
    end,
    SetOverrideBindingClick = function(_, _, key, buttonName)
      return env.SetBindingClick(key, buttonName)
    end,
    SetRaidProfileOption = UNIMPLEMENTED,
    SetRaidProfileSavedPosition = UNIMPLEMENTED,
    SetTooltipMoney = UNIMPLEMENTED,
    ShoppingTooltip1 = CreateFrame('GameTooltip'),
    ShoppingTooltip2 = CreateFrame('GameTooltip'),
    ShoppingTooltip3 = CreateFrame('GameTooltip'),
    SlashCmdList = {},
    SpellHasRange = UNIMPLEMENTED,
    StaticPopupDialogs = {},
    StaticPopup_Show = UNIMPLEMENTED,
    strmatch = string.match,
    strsplit = function(sep, s, n)
      assert(n == nil)
      local result = {}
      while true do
        local pos = string.find(s, sep)
        if not pos then
          table.insert(result, s)
          return unpack(result)
        end
        table.insert(result, s:sub(0, pos - 1))
        s = s:sub(pos + 1)
      end
    end,
    TargetFrame = CreateFrame('Button'),
    TemporaryEnchantFrame = CreateFrame('Frame'),
    TimeManagerClockButton = CreateFrame('Frame'),
    TOOLTIP_UPDATE_TIME = 0.2,
    UIParent = CreateFrame('Frame'),
    UnitAura = UNIMPLEMENTED,
    UnitBuff = function(unit, index)
      if unit == 'player' then
        return nil, nil, nil, nil, nil, nil, nil, nil, nil, state.buffs[index]
      end
    end,
    UnitClass = function(unit)
      if unit == 'player' then
        local name, filename = unpack(unitClasses[state.player.class])
        return name, filename, state.player.class
      else
        return nil
      end
    end,
    UnitClassBase = function(unit)
      if unit == 'player' then
        local _, filename = unpack(unitClasses[state.player.class])
        return filename, state.player.class
      else
        return nil
      end
    end,
    UnitDebuff = UNIMPLEMENTED,
    UnitExists = function(unit)
      return unit == 'player'
    end,
    UnitGetIncomingHeals = UNIMPLEMENTED,
    UnitGUID = function(unit)
      return 'GUID:' .. unit
    end,
    UnitHasIncomingResurrection = UNIMPLEMENTED,
    UnitHealth = function()
      return state.player.health
    end,
    UnitHealthMax = function()
      return state.player.healthmax
    end,
    UnitInParty = function()
      return state.inGroup
    end,
    UnitInRaid = UNIMPLEMENTED,
    UnitInRange = UNIMPLEMENTED,
    UnitIsConnected = UNIMPLEMENTED,
    UnitIsDeadOrGhost = UNIMPLEMENTED,
    UnitIsUnit = UNIMPLEMENTED,
    UnitLevel = function()
      return state.player.level
    end,
    UnitName = function()
      return state.player.name
    end,
    UnitPosition = function()
      return 0, 0
    end,
    UnitPower = function()
      return state.player.power
    end,
    UnitPowerMax = function()
      return state.player.powermax
    end,
    UnitPowerType = function()
      return nil, 'MANA'
    end,
    UnitRace = function()
      return state.player.race
    end,
    UnitXP = UNIMPLEMENTED,
    UnitXPMax = UNIMPLEMENTED,
    unpack = unpack,
    wipe = function(t)
      for k, _ in pairs(t) do
        t[k] = nil
      end
    end,
    WorldFrame = CreateFrame('Frame'),
    WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5,
    WOW_PROJECT_CLASSIC = 2,
    WOW_PROJECT_ID = 2,
    WOW_PROJECT_MAINLINE = 1,
  }
  return Mixin(env, wowapi), state
end
