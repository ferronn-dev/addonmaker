local UNIMPLEMENTED = function() end

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

local function CreateFrameImpl(state, className, frameName, parent, templates)
  local CreateFrame = function(...)
    return CreateFrameImpl(state, ...)
  end
  local hierarchy = {
    Alpha = {
      inherits = {'Animation'},
      api = {
        SetFromAlpha = UNIMPLEMENTED,
        SetToAlpha = UNIMPLEMENTED,
      },
    },
    Animation = {
      inherits = {'ScriptObject', 'UIObject'},
      api = {
        SetDuration = UNIMPLEMENTED,
        SetOrder = UNIMPLEMENTED,
        SetStartDelay = UNIMPLEMENTED,
      },
    },
    AnimationGroup = {
      inherits = {'Region', 'ScriptObject'},
      api = {
        CreateAnimation = function(self, animType)
          return CreateFrame(animType, nil, self)
        end,
        SetToFinalAlpha = UNIMPLEMENTED,
        Stop = UNIMPLEMENTED,
      },
    },
    Button = {
      inherits = {'Frame'},
      scripts = {'PreClick', 'OnClick', 'PostClick'},
      api = {
        Click = function(self, ...)
          RunScript(self, 'PreClick', ...)
          RunScript(self, 'OnClick', ...)
          RunScript(self, 'PostClick', ...)
        end,
        Enable = UNIMPLEMENTED,
        GetHighlightTexture = function(self)
          return self.highlightTexture
        end,
        GetNormalTexture = function(self)
          return self.normalTexture
        end,
        GetPushedTexture = function(self)
          return self.pushedTexture
        end,
        RegisterForClicks = UNIMPLEMENTED,
        SetHighlightFontObject = UNIMPLEMENTED,
        SetHighlightTexture = function(self)
          self.highlightTexture = self:CreateTexture()
        end,
        SetNormalFontObject = UNIMPLEMENTED,
        SetNormalTexture = function(self)
          self.normalTexture = self:CreateTexture()
        end,
        SetPushedTexture = function(self)
          self.pushedTexture = self:CreateTexture()
        end,
        SetText = UNIMPLEMENTED,
      },
    },
    Cooldown = {
      inherits = {'Frame'},
      api = {
        SetReverse = UNIMPLEMENTED,
      }
    },
    FontInstance = {
      data = {'fontObject'},
      api = {
        GetFontObject = function(self)
          return self.fontObject
        end,
        SetFontObject = function(self, fontObject)
          self.fontObject = fontObject
        end,
        SetJustifyH = UNIMPLEMENTED,
        SetJustifyV = UNIMPLEMENTED,
        SetTextColor = UNIMPLEMENTED,
      },
    },
    FontString = {
      inherits = {'FontInstance', 'LayeredRegion'},
      api = {
        SetText = UNIMPLEMENTED,
      },
    },
    Frame = {
      inherits = {'Region', 'ScriptObject'},
      data = {'attributes', 'registeredEvents'},
      scripts = {'OnEvent', 'OnUpdate'},
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
        SetClampRectInsets = UNIMPLEMENTED,
        SetFrameLevel = UNIMPLEMENTED,
        SetFrameStrata = UNIMPLEMENTED,
        SetMinResize = UNIMPLEMENTED,
        SetMouseClickEnabled = UNIMPLEMENTED,
        SetMovable = UNIMPLEMENTED,
        SetResizable = UNIMPLEMENTED,
        SetScale = UNIMPLEMENTED,
        SetToplevel = UNIMPLEMENTED,
        SetUserPlaced = UNIMPLEMENTED,
        UnregisterAllEvents = UNIMPLEMENTED,
      },
    },
    GameTooltip = {
      inherits = {'Frame'},
      data = {'lines'},
      scripts = {'OnTooltipSetItem', 'OnTooltipSetSpell', 'OnTooltipSetUnit'},
      api = {
        AddDoubleLine = function(self, l, r, lr, lg, lb, rr, rg, rb)
          table.insert(self.lines, {
              l = l, r = r,
              lr = lr, lg = lg, lb = lb,
              rr = rr, rg = rg, rb = rb
          })
        end,
        AddLine = function(self, s, r, g, b)
          self:AddDoubleLine(s, nil, r, g, b, nil, nil, nil)
        end,
        GetItem = function(self)
          return self.item
        end,
        GetSpell = function(self)
          return self.spell
        end,
        GetUnit = function(self)
          return self.unit
        end,
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
      inherits = {'Region'},
      api = {
        SetVertexColor = UNIMPLEMENTED,
      },
    },
    MessageFrame = {
      inherits = {'Frame', 'FontInstance'},
    },
    Minimap = {
      inherits = {'Frame'},
      api = {
        SetMaskTexture = UNIMPLEMENTED,
        SetZoom = UNIMPLEMENTED,
      },
    },
    Region = {
      inherits = {'UIObject', 'ScriptObject'},
      api = {
        ClearAllPoints = UNIMPLEMENTED,
        CreateAnimationGroup = function(self)
          return CreateFrame('AnimationGroup', nil, self)
        end,
        GetCenter = UNIMPLEMENTED,
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
        SetHeight = function(self, value)
          self.height = value
        end ,
        SetParent = UNIMPLEMENTED,
        SetPoint = UNIMPLEMENTED,
        SetSize = UNIMPLEMENTED,
        SetWidth = UNIMPLEMENTED,
        Show = function(self, ...)
          self.shown = true
          RunScript(self, 'OnShow', ...)
        end,
      },
    },
    ScriptObject = {
      data = {'scripts'},
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
      }
    },
    ScrollFrame = {
      inherits = {'Frame'},
      api = {
        SetScrollChild = UNIMPLEMENTED,
      },
    },
    Slider = {
      inherits = {'Frame'},
      api = {
        SetMinMaxValues = UNIMPLEMENTED,
        SetValue = UNIMPLEMENTED,
        SetValueStep = UNIMPLEMENTED,
      },
    },
    StatusBar = {
      inherits = {'Frame'},
      api = {
        SetMinMaxValues = UNIMPLEMENTED,
        SetStatusBarColor = UNIMPLEMENTED,
        SetStatusBarTexture = UNIMPLEMENTED,
        SetValue = UNIMPLEMENTED,
      },
    },
    Texture = {
      inherits = {'LayeredRegion'},
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
        GetParent = function(self)
          return self.parent
        end,
        SetAlpha = UNIMPLEMENTED,
      },
    },
  }
  local mixins = {
    CooldownFrameTemplate = {},
    GameTooltipTemplate = {},
    SecureActionButtonTemplate = {
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
      end
    },
    SecureHandlerStateTemplate = {},
    SecureUnitButtonTemplate = {},
  }
  local toProcess = {className}
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
    for _, v in ipairs(class.data or {}) do
      frame[v] = {}
    end
    for k, v in pairs(class.api or {}) do
      frame[k] = v
    end
    for _, v in ipairs(class.scripts or {}) do
      table.insert(scripts, v)
    end
  end
  frame.parent = parent
  frame._type = className
  for _, v in ipairs(scripts) do
    frame:SetScript(v, function() end)
  end
  for t in string.gmatch(templates or '', '[^,]+') do
    assert(mixins[t] ~= nil, 'unknown mixin ' .. t)
    for k, v in pairs(mixins[t]) do
      frame:SetScript(k, v)
    end
  end
  if classes['Frame'] then
    table.insert(state.frames, frame)
  end
  if frameName then
    state.frames[frameName] = frame
  end
  return frame
end

return function()
  local state
  local CreateFrame = function(...)
    return CreateFrameImpl(state, ...)
  end
  state = {
    bindings = {},
    commands = {},
    frames = {},
    player = {
      class = 2,
      health = 1500,
      healthmax = 2000,
      level = 42,
      name = 'Kewhand',
      power = 1000,
      powermax = 1250,
    },
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
      local name = 'nameplate'..index
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
  }
  local wowapi = {
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
    C_Map = {
      GetBestMapForUnit = UNIMPLEMENTED,
      GetMapInfo = UNIMPLEMENTED,
    },
    C_NamePlate = {
      GetNamePlateForUnit = function(unit)
        if unit:sub(1, 9) == 'nameplate' then
          return state.nameplates[tonumber(unit:sub(10))].np
        end
      end,
    },
    C_Timer = {
      NewTicker = function(interval, func)
        table.insert(state.tickers, {
          interval = interval,
          func = func,
        })
      end
    },
    ChatFrame1 = CreateFrame('MessageFrame'),
    CreateFrame = CreateFrame,
    DisableAddOn = UNIMPLEMENTED,
    EquipItemByName = function(item, slot)
      state.equipment[slot] = item
    end,
    ERR_LEARN_SPELL_S = 'You have learned a new spell: %s.',
    format = string.format,
    GameTooltip = CreateFrame('GameTooltip', 'GameTooltip'),
    GetAddOnEnableState = UNIMPLEMENTED,
    GetClassColor = UNIMPLEMENTED,
    GetContainerItemInfo = UNIMPLEMENTED,
    GetContainerNumFreeSlots = function()
      return 2
    end,
    GetContainerNumSlots = function()
      return 4
    end,
    GetBindingByKey = function(key)
      return state.bindings[key]
    end,
    GetCraftInfo = function(index)
      return table.unpack(state.crafts[index])
    end,
    GetFramerate = function()
      return 100
    end,
    GetInstanceInfo = UNIMPLEMENTED,
    GetInventoryItemDurability = UNIMPLEMENTED,
    GetInventoryItemID = UNIMPLEMENTED,
    GetInventoryItemLink = UNIMPLEMENTED,
    GetItemCooldown = function()
      return 0
    end,
    GetItemCount = function(item)
      return state.inventory[item] or 0
    end,
    GetLocale = UNIMPLEMENTED,
    GetMoney = UNIMPLEMENTED,
    GetNumCrafts = function()
      return #state.crafts
    end,
    GetNumGroupMembers = function()
      return 0
    end,
    GetNumTalentTabs = function()
      return 0
    end,
    GetRealZoneText = UNIMPLEMENTED,
    GetServerTime = function()
      return state.serverTime
    end,
    GetSpellCooldown = function()
      return 0
    end,
    GetSpellInfo = function(spell)
      return 'spell'..spell, nil, 12345, 0
    end,
    GetSpellSubtext = UNIMPLEMENTED,
    GetTime = function()
      return state.localTime
    end,
    GetTrackingTexture = UNIMPLEMENTED,
    hooksecurefunc = UNIMPLEMENTED,
    InCombatLockdown = function()
      return state.inCombat
    end,
    InterfaceOptions_AddCategory = UNIMPLEMENTED,
    InterfaceOptionsFrame_OpenToCategory = UNIMPLEMENTED,
    IsInGroup = function()
      return state.inGroup
    end,
    IsInInstance = UNIMPLEMENTED,
    IsMounted = function()
      return state.isMounted
    end,
    IsSpellKnown = function(spell)
      return state:IsSpellKnown(spell)
    end,
    IsUsableSpell = function(spell)
      return state:IsSpellKnown(spell), false
    end,
    ItemRefTooltip = CreateFrame('GameTooltip'),
    MainMenuBar = CreateFrame('Frame'),
    Minimap = CreateFrame('Minimap'),
    MinimapBackdrop = CreateFrame('Frame'),
    MinimapCluster = CreateFrame('Frame'),
    NUM_BAG_SLOTS = 4,
    PlayerFrame = CreateFrame('Button'),
    PowerBarColor = {MANA = {r=0.5, g=0.5, b=0.5}},
    RaidFrame = CreateFrame('Frame'),
    RegisterAttributeDriver = UNIMPLEMENTED,
    RegisterUnitWatch = UNIMPLEMENTED,
    SetBinding = function(key, command)
      state.bindings[key] = command
      return true
    end,
    SetBindingClick = function(key, buttonName)
      state.bindings[key] = 'CLICK '..buttonName
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
    SetRaidProfileOption = UNIMPLEMENTED,
    SetRaidProfileSavedPosition = UNIMPLEMENTED,
    ShoppingTooltip1 = CreateFrame('GameTooltip'),
    ShoppingTooltip2 = CreateFrame('GameTooltip'),
    ShoppingTooltip3 = CreateFrame('GameTooltip'),
    SlashCmdList = {},
    StaticPopupDialogs = {},
    strmatch = string.match,
    strsplit = function(sep, s, n)
      assert(n == nil)
      local result = {}
      for w in string.gmatch(s, '([^'..sep..']+)') do
        table.insert(result, w)
      end
      return table.unpack(result)
    end,
    TargetFrame = CreateFrame('Button'),
    TimeManagerClockButton = CreateFrame('Frame'),
    UnitBuff = function(unit, index)
      if unit == 'player' then
        return nil, nil, nil, nil, nil, nil, nil, nil, nil, state.buffs[index]
      end
    end,
    UnitClass = function(unit)
      assert(unit == 'player')
      local name, filename = table.unpack(unitClasses[state.player.class])
      return name, filename, state.player.class
    end,
    UnitClassBase = function(unit)
      assert(unit == 'player')
      local _, filename = table.unpack(unitClasses[state.player.class])
      return filename, state.player.class
    end,
    UnitDebuff = UNIMPLEMENTED,
    UnitExists = function(unit)
      return unit == 'player'
    end,
    UnitHealth = function()
      return state.player.health
    end,
    UnitHealthMax = function()
      return state.player.healthmax
    end,
    UnitInRange = UNIMPLEMENTED,
    UnitInParty = function()
      return true
    end,
    UnitIsDeadOrGhost = UNIMPLEMENTED,
    UnitIsUnit = UNIMPLEMENTED,
    UnitLevel = function()
      return state.player.level
    end,
    UnitName = function()
      return state.player.name
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
      return 'Human'
    end,
    UnitXP = UNIMPLEMENTED,
    UnitXPMax = UNIMPLEMENTED,
    unpack = table.unpack,
    wipe = function(t)
      for k, _ in pairs(t) do
        t[k] = nil
      end
    end,
  }
  return wowapi, state
end
