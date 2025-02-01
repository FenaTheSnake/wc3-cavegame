namespace GUI {
    namespace Menus {
        namespace WorldCreation {

            framehandle but_CreateNewSave;
            framehandle but_OpenSave;
            framehandle but_Exit;
            framehandle but_UpdateList;
            framehandle but_PrevPage;
            framehandle but_NextPage;
            framehandle txt_WorldName;
            framehandle txt_WorldName_shadow;
            framehandle edt_WorldName;

            framehandle lst_Worlds;
            array<framehandle> lst_WorldsItems;
            framehandle currentSelectedWorldItem;

            trigger onCreateButtonClicked;
            trigger onOpenButtonClicked;
            trigger onExitClicked;
            trigger onUpdateListClicked;
            trigger onPrevPageClicked;
            trigger onNextPageClicked;

            trigger onWorldsListClick;
            trigger onWorldsListTextClick;

            int worldListPage = 0;
            array<string>@ worldNames;

            void OnCreateNewWorld() {
                if(!Multiplayer::isHost) return;
                if(GetFrameText(edt_WorldName).length() < 2) return;
                Multiplayer::SendCreateNewWorld(GetFrameText(edt_WorldName));
                Hide();
            }
            
            void OnOpenWorld() {
                if(!Multiplayer::isHost) return;
                if(GetFrameText(edt_WorldName).length() < 2) return;
                if(!Save::IsWorldExists(GetFrameText(edt_WorldName))) return;
                Multiplayer::SendSyncWorld(GetFrameText(edt_WorldName));
                Hide();
            }

            void OnExit() {
                EndGame(false);
            }

            void SelectWorld(framehandle worldFrame) {
                framehandle txtFrame = GetFrameChild(worldFrame, 0);
                SetFrameText(edt_WorldName, GetFrameText(txtFrame));

                SetFrameTextColour(txtFrame, 0xFFEEEE22);
                if(currentSelectedWorldItem != nil) {
                    SetFrameTextColour(GetFrameChild(currentSelectedWorldItem, 0), 0xFFFFFFFF);
                }
                currentSelectedWorldItem = worldFrame;
            }

            void OnWorldListItemClick() {
                SelectWorld(lst_WorldsItems[GetTriggerFrameInteger()]);
            }

            void OnWorldListTextClick() {
                SelectWorld(GetFrameParent(GetTriggerFrame()));
            }

            void ShowCurrentPage() {
                for(int i = 0; i < lst_WorldsItems.length(); i++) {
                    ShowFrame(lst_WorldsItems[i], false);
                }

                for(int i = 0; i < WORLD_LIST_PAGE_ITEMS_COUNT; i++) {
                    int wrldId = i + worldListPage * WORLD_LIST_PAGE_ITEMS_COUNT;
                    if(wrldId < 0 || wrldId >= worldNames.length()) return;
                    
                    ShowFrame(lst_WorldsItems[i], true);
                    SetFrameText(GetFrameChild(lst_WorldsItems[i], 0), worldNames[wrldId]);
                }
            }
            void OnUpdateListClicked() {
                ShowCurrentPage();
            }
            void OnPrevPageClicked() {
                worldListPage -= 1;
                ShowCurrentPage();
            }
            void OnNextPageClicked() {
                worldListPage += 1;
                ShowCurrentPage();
            }

            void Init() {
                LoadTOCFile("war3mapImported\\so.toc");

                framehandle gameUI = GetOriginFrame( ORIGIN_FRAME_GAME_UI, 0 );

                but_CreateNewSave = CreateFrameByType("GLUETEXTBUTTON", "MyScriptDialogButton", gameUI, "ScriptDialogButton", 0);
                SetFrameRelativePoint(but_CreateNewSave, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.325, -0.1);
                SetFrameText(but_CreateNewSave, "New World");
                SetFrameSize(but_CreateNewSave, .1, .03);
                ShowFrame(but_CreateNewSave, true);

                onCreateButtonClicked = CreateTrigger();
                TriggerRegisterFrameEvent(onCreateButtonClicked, but_CreateNewSave, FRAMEEVENT_CONTROL_CLICK);
                TriggerAddAction(onCreateButtonClicked, @OnCreateNewWorld);

                but_OpenSave = CreateFrameByType("GLUETEXTBUTTON", "MyScriptDialogButton", gameUI, "ScriptDialogButton", 1);
                SetFrameRelativePoint(but_OpenSave, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.44, -0.1);
                SetFrameText(but_OpenSave, "Load World");
                SetFrameSize(but_OpenSave, .1, .03);
                ShowFrame(but_OpenSave, true);

                onOpenButtonClicked = CreateTrigger();
                TriggerRegisterFrameEvent(onOpenButtonClicked, but_OpenSave, FRAMEEVENT_CONTROL_CLICK);
                TriggerAddAction(onOpenButtonClicked, @OnOpenWorld);

                but_Exit = CreateFrameByType("GLUETEXTBUTTON", "MyScriptDialogButton", gameUI, "ScriptDialogButton", 2);
                SetFrameRelativePoint(but_Exit, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.55, -0.1);
                SetFrameText(but_Exit, "Exit");
                SetFrameSize(but_Exit, .1, .03);
                ShowFrame(but_Exit, true);

                onExitClicked = CreateTrigger();
                TriggerRegisterFrameEvent(onExitClicked, but_Exit, FRAMEEVENT_CONTROL_CLICK);
                TriggerAddAction(onExitClicked, @OnExit);

                txt_WorldName_shadow = CreateFrameByType("TEXT", "MyTextFrame", gameUI, "", 0);
                SetFrameText(txt_WorldName_shadow, "|c11111100World name:|r");
                SetFrameRelativePoint(txt_WorldName_shadow, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.1 + 0.00075, -0.085 - 0.00075);
                txt_WorldName = CreateFrameByType("TEXT", "MyTextFrame", gameUI, "", 1);
                SetFrameText(txt_WorldName, "|cffffcc00World name:|r");
                SetFrameRelativePoint(txt_WorldName, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.1, -0.085);

                edt_WorldName = CreateFrame("EscMenuEditBoxTemplate", gameUI, 0, 0);
                SetFrameRelativePoint(edt_WorldName, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.1, -0.1);
                SetFrameSize(edt_WorldName, 0.2, 0.03);
                ShowFrame(edt_WorldName, true);
                SetFrameTextSizeLimit(edt_WorldName, 60);

                lst_Worlds = CreateFrameByType("LISTBOX", "WorldsListBox", gameUI, "", 0);
                ClearFrameAllPoints(lst_Worlds);
                SetFrameRelativePoint(lst_Worlds, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.1, -0.14);
                SetFrameSize(lst_Worlds, 0.625, 0.35);
                SetFrameItemsBorder(lst_Worlds, .01);
                SetFrameItemsHeight(lst_Worlds, .04);
                SetFrameControlFlag(lst_Worlds, CONTROL_STYLE_HIGHLIGHT_FOCUS, true);
                SetFrameBackdropTexture( lst_Worlds, 1, "UI\\widgets\\BattleNet\\bnet-tooltip-background.blp", true, true, "UI\\widgets\\BattleNet\\bnet-tooltip-border.blp", BORDER_FLAG_ALL, false );
                SetFrameBorderSize( lst_Worlds, 1, .0125 );
                SetFrameBackgroundSize( lst_Worlds, 1, .256 );
                SetFrameBackgroundInsets( lst_Worlds, 1, .005, .005, .005, .005 );
                AddFrameSlider( lst_Worlds );

                onWorldsListTextClick = CreateTrigger();
                TriggerAddAction(onWorldsListTextClick, @OnWorldListTextClick);
                CreateWorldList();

                onWorldsListClick = CreateTrigger();
                TriggerRegisterFrameEvent(onWorldsListClick, lst_Worlds, FRAMEEVENT_POPUPMENU_ITEM_CHANGED);
                TriggerAddAction(onWorldsListClick, @OnWorldListItemClick);

                but_UpdateList = CreateFrameByType("GLUETEXTBUTTON", "MyScriptDialogButton", gameUI, "ScriptDialogButton", 3);
                SetFrameRelativePoint(but_UpdateList, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.1, -0.5);
                SetFrameText(but_UpdateList, "Update");
                SetFrameSize(but_UpdateList, .1, .03);
                ShowFrame(but_UpdateList, true);
                onUpdateListClicked = CreateTrigger();
                TriggerRegisterFrameEvent(onUpdateListClicked, but_UpdateList, FRAMEEVENT_CONTROL_CLICK);
                TriggerAddAction(onUpdateListClicked, @OnUpdateListClicked);

                but_PrevPage = CreateFrameByType("GLUETEXTBUTTON", "MyScriptDialogButton", gameUI, "ScriptDialogButton", 4);
                SetFrameRelativePoint(but_PrevPage, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.2, -0.5);
                SetFrameText(but_PrevPage, "<");
                SetFrameSize(but_PrevPage, .03, .03);
                ShowFrame(but_PrevPage, true);
                onPrevPageClicked = CreateTrigger();
                TriggerRegisterFrameEvent(onPrevPageClicked, but_PrevPage, FRAMEEVENT_CONTROL_CLICK);
                TriggerAddAction(onPrevPageClicked, @OnPrevPageClicked);

                but_NextPage = CreateFrameByType("GLUETEXTBUTTON", "MyScriptDialogButton", gameUI, "ScriptDialogButton", 5);
                SetFrameRelativePoint(but_NextPage, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.23, -0.5);
                SetFrameText(but_NextPage, ">");
                SetFrameSize(but_NextPage, .03, .03);
                ShowFrame(but_NextPage, true);
                onNextPageClicked = CreateTrigger();
                TriggerRegisterFrameEvent(onNextPageClicked, but_NextPage, FRAMEEVENT_CONTROL_CLICK);
                TriggerAddAction(onNextPageClicked, @OnNextPageClicked);

                GenerateWorldList();
                Hide();
            }

            void CreateWorldList() {
                float itemHeight = GetFrameItemsHeight(lst_Worlds);
                framehandle listScrollFrame = GetFrameChild(lst_Worlds, 2);

                framehandle backDropFrame, listItemFrame, textFrame, subtextFrame, playButton;
                for(int i = 0; i < WORLD_LIST_PAGE_ITEMS_COUNT; i++) {
                    backDropFrame = CreateFrameByType( "BACKDROP", "WorldListItemBackDrop", listScrollFrame, "", i );
                    listItemFrame = AddFrameListItem( lst_Worlds, "", backDropFrame );
                    lst_WorldsItems.insertLast(listItemFrame);
                    SetFrameControlFlag( listItemFrame, CONTROL_STYLE_EXCLUSIVE, false );
                    SetFrameBackdropTexture( backDropFrame, 1, "UI\\widgets\\BattleNet\\bnet-tooltip-background.blp", true, true, "UI\\widgets\\BattleNet\\bnet-tooltip-border.blp", BORDER_FLAG_ALL, false );
                    SetFrameHeight( backDropFrame, .04 );
                    SetFrameBorderSize( backDropFrame, 1, .0125 );
                    SetFrameBackgroundSize( backDropFrame, 1, .128 );
                    SetFrameBackgroundInsets( backDropFrame, 1, .005, .005, .005, .005 );

                    textFrame = CreateFrameByType( "TEXT", "WorldListItemText", listItemFrame, "", i );
                    SetFrameControlFlag( textFrame, CONTROL_STYLE_EXCLUSIVE, false );
                    ClearFrameAllPoints( textFrame );
                    SetFrameRelativePoint( textFrame, FRAMEPOINT_LEFT, listItemFrame, FRAMEPOINT_LEFT, .005, .0 );
                    SetFrameText( textFrame, "Item " + i );
                    SetFrameScale(textFrame, 1.25f);
                    TriggerRegisterFrameEvent(onWorldsListTextClick, textFrame, FRAMEEVENT_CONTROL_CLICK);

                    subtextFrame = CreateFrameByType( "TEXT", "WorldListItemSubText", listItemFrame, "", i );
                    ClearFrameAllPoints( subtextFrame );
                    SetFrameText( subtextFrame, "|cffAAAAAASample text description idk hello blabla" );
                    SetFrameRelativePoint( subtextFrame, FRAMEPOINT_BOTTOMRIGHT, listItemFrame, FRAMEPOINT_BOTTOMRIGHT, -.015, .01 );
                    SetFrameScale(subtextFrame, 0.75f);

                    // playButton = CreateFrameByType("GLUETEXTBUTTON", "WorldListItemButton", backDropFrame, "ScriptDialogButton", 4+i);
                    // SetFrameRelativePoint(playButton, FRAMEPOINT_LEFT, backDropFrame, FRAMEPOINT_LEFT, 0.015, 0.0);
                    // SetFrameText(playButton, ">");
                    // SetFrameSize(playButton, .02, .03);
                    // ShowFrame(playButton, true);
                }
            }

            void GenerateWorldList() {
                if(!Multiplayer::isHost) return;
                @worldNames = @Save::Global::GetWorldList();
            }

            void Show() {
                ShowFrame(but_CreateNewSave, true);
                ShowFrame(but_OpenSave, true);
                ShowFrame(but_Exit, true);
                ShowFrame(but_UpdateList, true);
                ShowFrame(but_PrevPage, true);
                ShowFrame(but_NextPage, true);
                ShowFrame(txt_WorldName, true);
                ShowFrame(txt_WorldName_shadow, true);
                ShowFrame(edt_WorldName, true);
                ShowFrame(lst_Worlds, true);

                ShowCurrentPage();
            }

            void Hide() {
                SetFrameFocus(but_CreateNewSave, false);
                SetFrameFocus(but_OpenSave, false);
                SetFrameFocus(but_Exit, false);
                SetFrameFocus(but_UpdateList, false);
                SetFrameFocus(but_PrevPage, false);
                SetFrameFocus(but_NextPage, false);
                SetFrameFocus(txt_WorldName, false);
                SetFrameFocus(txt_WorldName_shadow, false);
                SetFrameFocus(edt_WorldName, false);
                SetFrameFocus(lst_Worlds, false);

                ShowFrame(but_CreateNewSave, false);
                ShowFrame(but_OpenSave, false);
                ShowFrame(but_Exit, false);
                ShowFrame(but_UpdateList, false);
                ShowFrame(but_PrevPage, false);
                ShowFrame(but_NextPage, false);
                ShowFrame(txt_WorldName, false);
                ShowFrame(txt_WorldName_shadow, false);
                ShowFrame(edt_WorldName, false);
                ShowFrame(lst_Worlds, false);
            }
        }

    }
}