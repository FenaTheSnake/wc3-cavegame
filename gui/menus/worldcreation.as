namespace GUI {
    namespace Menus {
        namespace WorldCreation {

            framehandle but_CreateNewSave;
            framehandle but_OpenSave;
            framehandle but_Exit;
            framehandle txt_WorldName;
            framehandle txt_WorldName_shadow;
            framehandle edt_WorldName;

            framehandle lst_Worlds;

            trigger onCreateButtonClicked;
            trigger onOpenButtonClicked;
            trigger onExitClicked;
            trigger onWorldsListClick;

            void OnCreateNewWorld() {
                if(!Multiplayer::isHost) return;
                Multiplayer::SendCreateNewWorld(GetFrameText(edt_WorldName));
                Hide();
            }
            
            void OnOpenWorld() {

            }

            void OnExit() {
                EndGame(false);
            }

            void debug() {
                __debug("abdc " + GetTriggerFrameInteger());
            }

            void Init() {
                LoadTOCFile("war3mapImported\\so.toc");

                framehandle gameUI = GetOriginFrame( ORIGIN_FRAME_GAME_UI, 0 );

                but_CreateNewSave = CreateFrameByType("GLUETEXTBUTTON", "MyScriptDialogButton", gameUI, "ScriptDialogButton", 0);
                SetFrameRelativePoint(but_CreateNewSave, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.325, -0.1);
                SetFrameText(but_CreateNewSave, "Create New World");
                SetFrameSize(but_CreateNewSave, .1, .03);
                ShowFrame(but_CreateNewSave, true);

                onCreateButtonClicked = CreateTrigger();
                TriggerRegisterFrameEvent(onCreateButtonClicked, but_CreateNewSave, FRAMEEVENT_CONTROL_CLICK);
                TriggerAddAction(onCreateButtonClicked, @OnCreateNewWorld);

                but_OpenSave = CreateFrameByType("GLUETEXTBUTTON", "MyScriptDialogButton", gameUI, "ScriptDialogButton", 1);
                SetFrameRelativePoint(but_OpenSave, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.44, -0.1);
                SetFrameText(but_OpenSave, "Open World");
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
                SetFrameSize(lst_Worlds, 0.625, 0.4);
                SetFrameItemsBorder(lst_Worlds, .01);
                SetFrameItemsHeight(lst_Worlds, .04);
                SetFrameControlFlag(lst_Worlds, CONTROL_STYLE_HIGHLIGHT_FOCUS, true);
                SetFrameBackdropTexture( lst_Worlds, 1, "UI\\widgets\\BattleNet\\bnet-tooltip-background.blp", true, true, "UI\\widgets\\BattleNet\\bnet-tooltip-border.blp", BORDER_FLAG_ALL, false );
                SetFrameBorderSize( lst_Worlds, 1, .0125 );
                SetFrameBackgroundSize( lst_Worlds, 1, .256 );
                SetFrameBackgroundInsets( lst_Worlds, 1, .005, .005, .005, .005 );
                AddFrameSlider( lst_Worlds );

                UpdateWorldList();

                onWorldsListClick = CreateTrigger();
                TriggerRegisterFrameEvent(onWorldsListClick, lst_Worlds, FRAMEEVENT_POPUPMENU_ITEM_CHANGED);
                TriggerAddAction(onWorldsListClick, @debug);

                Hide();
            }

            void UpdateWorldList() {
                array<string>@ worlds = Save::Global::GetWorldList();

                float itemHeight = GetFrameItemsHeight(lst_Worlds);
                framehandle listScrollFrame = GetFrameChild(lst_Worlds, 2);

                framehandle backDropFrame, listItemFrame, textFrame, subtextFrame, playButton;
                for(int i = 0; i < worlds.length(); i++) {
                    backDropFrame = CreateFrameByType( "BACKDROP", "MyTestBackDrop", listScrollFrame, "", i );
                    listItemFrame = AddFrameListItem( lst_Worlds, "", backDropFrame );
                    SetFrameBackdropTexture( backDropFrame, 1, "UI\\widgets\\BattleNet\\bnet-tooltip-background.blp", true, true, "UI\\widgets\\BattleNet\\bnet-tooltip-border.blp", BORDER_FLAG_ALL, false );
                    SetFrameHeight( backDropFrame, .04 );
                    SetFrameBorderSize( backDropFrame, 1, .0125 );
                    SetFrameBackgroundSize( backDropFrame, 1, .128 );
                    SetFrameBackgroundInsets( backDropFrame, 1, .005, .005, .005, .005 );
                    if(i == 0) {
                        //ClickFrame(backDropFrame);
                        //SetFrameFocus(backDropFrame, true);
                    }

                    textFrame = CreateFrameByType( "TEXT", "frm_ListBoxText", backDropFrame, "", i );
                    ClearFrameAllPoints( textFrame );
                    SetFrameRelativePoint( textFrame, FRAMEPOINT_LEFT, backDropFrame, FRAMEPOINT_LEFT, .005, .0 );
                    SetFrameText( textFrame, worlds[i] );
                    SetFrameScale(textFrame, 1.25f);

                    subtextFrame = CreateFrameByType( "TEXT", "frm_ListBoxText2", backDropFrame, "", i );
                    ClearFrameAllPoints( subtextFrame );
                    SetFrameText( subtextFrame, "|cffAAAAAASample text description idk hello blabla" );
                    SetFrameRelativePoint( subtextFrame, FRAMEPOINT_BOTTOMRIGHT, backDropFrame, FRAMEPOINT_BOTTOMRIGHT, -.015, .01 );
                    SetFrameScale(subtextFrame, 0.75f);

                    // playButton = CreateFrameByType("GLUETEXTBUTTON", "MyScriptDialogButton", backDropFrame, "ScriptDialogButton", 4+i);
                    // SetFrameRelativePoint(playButton, FRAMEPOINT_LEFT, backDropFrame, FRAMEPOINT_LEFT, 0.015, 0.0);
                    // SetFrameText(playButton, ">");
                    // SetFrameSize(playButton, .02, .03);
                    // ShowFrame(playButton, true);
                }
            }

            void Show() {
                ShowFrame(but_CreateNewSave, true);
                ShowFrame(but_OpenSave, true);
                ShowFrame(but_Exit, true);
                ShowFrame(txt_WorldName, true);
                ShowFrame(txt_WorldName_shadow, true);
                ShowFrame(edt_WorldName, true);
                ShowFrame(lst_Worlds, true);
            }

            void Hide() {
                SetFrameFocus(but_CreateNewSave, false);
                SetFrameFocus(but_OpenSave, false);
                SetFrameFocus(but_Exit, false);
                SetFrameFocus(txt_WorldName, false);
                SetFrameFocus(txt_WorldName_shadow, false);
                SetFrameFocus(edt_WorldName, false);
                SetFrameFocus(lst_Worlds, false);

                ShowFrame(but_CreateNewSave, false);
                ShowFrame(but_OpenSave, false);
                ShowFrame(but_Exit, false);
                ShowFrame(txt_WorldName, false);
                ShowFrame(txt_WorldName_shadow, false);
                ShowFrame(edt_WorldName, false);
                ShowFrame(lst_Worlds, false);
            }
        }

    }
}