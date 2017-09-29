

static BOOL menuItemWithKeyEquivalentMatchingEventRef_Shared(struct _NSCarbonMenuSearchReturn *_pRetVal, id self_, SEL _Sel, EventRef _pEventRef, id _pInMenu)
{
	OSType EventClass = GetEventClass(_pEventRef);

	if (EventClass == 'keyb')
	{
		UInt32 EventKind = GetEventKind(_pEventRef);
		if (EventKind == kEventRawKeyDown || EventKind == kEventRawKeyRepeat)
		{
			UInt32 KeyCode;
			UInt32 Modifiers;
			GetEventParameter(_pEventRef, kEventParamKeyModifiers, typeUInt32, NULL, sizeof(UInt32), NULL, &Modifiers);
			GetEventParameter(_pEventRef, kEventParamKeyCode, typeUInt32, NULL, sizeof(UInt32), NULL, &KeyCode);

			NSUInteger nsModifiers = 0;
			if (Modifiers & cmdKey)
				nsModifiers |= NSEventModifierFlagCommand;
			if (Modifiers & controlKey)
				nsModifiers |= NSEventModifierFlagControl;
			if (Modifiers & optionKey)
				nsModifiers |= NSEventModifierFlagOption;
			if (Modifiers & shiftKey)
				nsModifiers |= NSEventModifierFlagShift;

			if (handleFieldEditorEvent(KeyCode, nsModifiers, nil))
			{
				// Don't let menu handle event
				_pRetVal->_field2 = nil;
				_pRetVal->_field1 = nil;
				_pRetVal->_field3 = 0;
				return true;
			}
		}
	}
	return false;
}

// + (struct _NSCarbonMenuSearchReturn)_menuItemWithKeyEquivalentMatchingEventRef:(struct OpaqueEventRef *)arg1 inMenu:(id)arg2;
static void menuItemWithKeyEquivalentMatchingEventRef(struct _NSCarbonMenuSearchReturn *_pRetVal, id self_, SEL _Sel, EventRef _pEventRef, id _pInMenu)
{
	if (menuItemWithKeyEquivalentMatchingEventRef_Shared(_pRetVal, self_, _Sel, _pEventRef, _pInMenu))
		return;
	return ((void(*)(struct _NSCarbonMenuSearchReturn *, id, SEL, EventRef, id))original_menuItemWithKeyEquivalentMatchingEventRef)(_pRetVal, self_, _Sel, _pEventRef, _pInMenu);
}

// + (struct _NSCarbonMenuSearchReturn)_menuItemWithKeyEquivalentMatchingEventRef:(struct OpaqueEventRef *)arg1 inMenu:(id)arg2 includingDisabledItems:(BOOL)arg3;
static void menuItemWithKeyEquivalentMatchingEventRef_macOS1012(struct _NSCarbonMenuSearchReturn *_pRetVal, id self_, SEL _Sel, EventRef _pEventRef, id _pInMenu, BOOL _includingDisabledItems)
{
	if (menuItemWithKeyEquivalentMatchingEventRef_Shared(_pRetVal, self_, _Sel, _pEventRef, _pInMenu))
		return;
	return ((void(*)(struct _NSCarbonMenuSearchReturn *, id, SEL, EventRef, id, BOOL))original_menuItemWithKeyEquivalentMatchingEventRef_macOS1012)(_pRetVal, self_, _Sel, _pEventRef, _pInMenu, _includingDisabledItems);
}
