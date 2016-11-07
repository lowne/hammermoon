local c=require'objc'
c.load'AppKit'
local nptr=c.nptr
--local super=c.callsuper
local NSMakeRect,NSMakePoint,NSMakeSize=c.NSMakeRect,c.NSMakePoint,c.NSMakeSize
local NSRectClip=c.NSRectClip
local NSColor=c.NSColor
local NSBezierPath=c.NSBezierPath
local NSGraphicsContext=c.NSGraphicsContext

local drawings=hm._core.retainValues()

local drawWindow=c.class('HMDrawingWindow','NSPanel <NSWindowDelegate>')
function drawWindow:windowShouldClose(_) return false end
local drawView=c.class('HMDrawingView','NSView')
function drawView:isFlipped()return 1 end
function drawView:drawRect(nsrect)
  local d=drawings[nptr(self)] or error'!'
  return d:_draw(nsrect)
end

local geometry=hm.geometry
local toCocoa=hm.screen._toCocoa
local sformat=string.format
local drawing=hm._core.module('drawing',{
  __tostring=function(self)return sformat('hm.drawing: [#%d] %s',self._ref,self._type) end
})
local draw,new=drawing._class,drawing._class._new
local log=drawing.log













local transparent,red,black=NSColor:clearColor(),NSColor:redColor(),NSColor:blackColor()
local defaultLineWidth=NSBezierPath:defaultLineWidth()
local drawingCount,drawMethod=0,{}
local NSBorderlessWindowMask,NSBackingStoreBuffered=c.NSBorderlessWindowMask,c.NSBackingStoreBuffered
local NSWindowAnimationBehaviorNone,NSScreenSaverWindowLevel=c.NSWindowAnimationBehaviorNone,c.NSScreenSaverWindowLevel
local function newDrawing(type,screenRect)
  local nsrect=toCocoa(screenRect):_toobj()
  local window=drawWindow:alloc():initWithContentRect_styleMask_backing_defer_(nsrect,NSBorderlessWindowMask,NSBackingStoreBuffered,1)
  --  window:setFrameTopLeftPoint(NSMakePoint(screenRect.x,screenRect.y))
  window.backgroundColor=transparent
  window.opaque=false window.hasShadow=false window.ignoreMouseEvents=true window.restorable=false window.hidesOnDeactivate=false
  window.animationBehavior=NSWindowAnimationBehaviorNone window.level=NSScreenSaverWindowLevel
  window.accessibilitySubrole="hammerspoonDrawing"
  --  local view=drawView:alloc():initWithFrame(window.contentView.frame)
  local view=drawView:alloc():initWithFrame(window.contentView.frame)
  window.contentView=view
  drawingCount=drawingCount+1
  local path=NSBezierPath:bezierPath()
  path.lineWidth=defaultLineWidth
  local o=new{_nswin=window,_nsview=view,_ref=drawingCount,_type=type,
    _fill=true,_fillColor=red,_stroke=true,_strokeColor=black,
    _drawRect=view.frame,
    _rrectx=0,_rrecty=0,
    _clipRect=nil,
    _path=path,
  --TODO rectclippingboundary
  --    _draw=drawMethod[type]
  }
  drawings[nptr(view)]=o
  return o
    --  view.hmdrawing=o
end



drawing.disableUpdates=c.NSDisableScreenUpdates
drawing.enableUpdates=c.NSEnableScreenUpdates

function draw:_draw(nsrect)
  --  print'============DRAW!!!================='
  --  local ctx=NSGraphicsContext:currentContext()
  --  ctx:saveGraphicsState()
  self._fillColor:setFill() self._strokeColor:setStroke()
  if self._clipRect then NSRectClip(self._clipRect) end
  local path=self._path
  path:removeAllPoints()
  local dtype=self._type
  if dtype=='rect' then
    path:appendBezierPathWithRoundedRect_xRadius_yRadius_(self._drawRect,self._rrectx,self._rrecty)
    --    path:appendBezierPathWithRect(self._drawRect)
  elseif dtype=='line' then
    path:moveToPoint(self._p1)
    path:lineToPoint(self._p2)
  elseif dtype=='circle' then
    path=NSBezierPath:bezierPathWithOvalInRect(self._drawRect)
    --    path:appendBezierPathWithOvalInRect(self._drawRect,self._drawRect) --doesn't work for some mysterious reason ("wrong number of arguments")
    -- cba to set line width etc.
  end
  --  path:setClip()
  if self._fill then path:fill() end
  if self._stroke then path:stroke() end
  --  ctx:restoreGraphicsState()
end





function drawing.rectangle(...)
  return newDrawing('rect',geometry(...))
end

function drawing.line(p1,p2)
  p1,p2=geometry(p1),geometry(p2)
  local o=newDrawing('line',geometry{x1=p1.x,y1=p1.y,x2=p2.x,y2=p2.y})
  o._p1=p1:_toobj()
  o._p2=p2:_toobj()
  return o
end

function drawing.circle(...)
  local rect=geometry(...)
  rect.aspect=1 -- make it a circle!
  return newDrawing('circle',rect)
end
function drawing.ellipse(...) return newDrawing('circle',geometry(...)) end

--local temprect=NSMakeRect(0,0,50,50)
--local tempoint=NSMakePoint(20,20)
--local tempsize=NSMakeSize(500,500)
function draw:setFrame(rect)
  rect=geometry(rect)
  self._drawRect=NSMakeRect(0,0,rect._w,rect._h)
  self._nswin:setContentSize(rect.wh:_toobj())
  self._nswin:setFrameOrigin(toCocoa(rect).xy:_toobj())
  --  self._drawRect=temprect
  --  self._nswin:setContentSize(tempsize)
  --  self._nswin:setFrameOrigin(tempoint)



  --  self._nswin:setFrameTopLeftPoint(rect.xy:_toobj())
  --  self._nswin:setFrame_display_(rect:_toobj(),true)
  return self
end

function draw:show()
  self._nswin:makeKeyAndOrderFront(nil) return self
end
function draw:hide()
  self._nswin:orderOut(nil) return self
end


return drawing
--[[






print(c.responds(drawWindow,'initWithContentRect:styleMask:backing:defer:'))
print(drawWindow)
print(c.classname(drawWindow))
print(c.classname('HMDrawingWindow'))
print'-------'
--c.class('HMDrawingWindow','NSObject')
--local HMDrawingWindow=c.HMDrawingWindow
c.class('HMDrawingView','NSView')

print(c.HMDrawingWindow['initWithContentRect:styleMask:backing:defer:'])
print(c.HMDrawingWindow.initWithContentRect_styleMask_backing_defer_)
--function HMDrawingWindow.initWithContentRect_styleMask_backing_defer_=function(self,rect,_,__,___)
function drawWindow:init(rect,_,__,___)
  print('const',self,rect)
  local o=super(self,'initWithContentRect:styleMask:backing:defer:',rect,c.NSBorderlessWindowMask,c.NSBackingStoreBuffered,true)
  print(self,o)
  return o
end
drawWindow.test=function(self)print(self)end
print(drawWindow.test)
drawWindow:test()
print(c.HMDrawingWindow.initWithContentRect_styleMask_backing_defer_)
print'/??'
--print(c.override(HMDrawingWindow,'initWithContentRect:styleMask:backing:defer:',function()print'dang'end))
print(c.HMDrawingWindow.initWithContentRect)
print(drawWindow['initWithContentRect:styleMask:backing:defer:'])
--]]
