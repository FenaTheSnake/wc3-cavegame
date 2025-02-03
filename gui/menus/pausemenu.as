namespace GUI {
    namespace Menus {
        namespace PauseMenu {
            framehandle but_Resume;
            framehandle but_SaveWorld;
            framehandle but_QuitWorld;

            framehandle bck_Settings;
            framehandle txt_RenderDistance;
            framehandle sld_RenderDistance;
            framehandle txt_GenSpeed;
            framehandle sld_GenSpeed;
            
            trigger onSettingsSliderValueChanged;

            trigger onResumeClicked;
            trigger onSaveClicked;
            trigger onQuitClicked;

            bool shown = false;

            void OnResume() {
                if(GetTriggerPlayer() != GetLocalPlayer()) return;
                Hide();
                GUI::HookCursor();
            }

            void OnSave() {
                if(GetTriggerPlayer() != GetLocalPlayer()) return;
                Hide();
                GUI::HookCursor();

                Main::overworld.Save();
            }

            void OnQuit() {
                if(GetTriggerPlayer() != GetLocalPlayer()) return;
                if(!Multiplayer::isHost) return;
                Hide();

                Multiplayer::SendEndGame();
            }

            void OnSettingsSlider() {
                if(GetTriggerPlayer() != GetLocalPlayer()) return;

                if(GetTriggerFrame() == sld_RenderDistance) {
                    int v = int(GetFrameValue(GetTriggerFrame()));
                    SetFrameText(txt_RenderDistance, "Render Distance: " + v + " (Default = 4)");
                    Main::renderDistance = v;
                }
                if(GetTriggerFrame() == sld_GenSpeed) {
                    float v = float(GetFrameValue(GetTriggerFrame())) * 0.01f;
                    SetFrameText(txt_GenSpeed, "Generation Speed: " + v + " (Default = 1)");
                    Main::genSpeed = v;
                }
            }

            void Init() {
                LoadTOCFile("war3mapImported\\so.toc");

                framehandle gameUI = GetOriginFrame( ORIGIN_FRAME_GAME_UI, 0 );

                but_Resume = CreateFrameByType("GLUETEXTBUTTON", "PauseMenuButton", gameUI, "ScriptDialogButton", 0);
                SetFrameRelativePoint(but_Resume, FRAMEPOINT_LEFT, gameUI, FRAMEPOINT_LEFT, 0.025, 0.1);
                SetFrameText(but_Resume, "Resume");
                SetFrameSize(but_Resume, .1, .03);
                ShowFrame(but_Resume, true);

                onResumeClicked = CreateTrigger();
                TriggerRegisterFrameEvent(onResumeClicked, but_Resume, FRAMEEVENT_CONTROL_CLICK);
                TriggerAddAction(onResumeClicked, @OnResume);

                but_SaveWorld = CreateFrameByType("GLUETEXTBUTTON", "PauseMenuButton", gameUI, "ScriptDialogButton", 1);
                SetFrameRelativePoint(but_SaveWorld, FRAMEPOINT_LEFT, gameUI, FRAMEPOINT_LEFT, 0.025, 0.05);
                SetFrameText(but_SaveWorld, "Save World");
                SetFrameSize(but_SaveWorld, .1, .03);
                ShowFrame(but_SaveWorld, true);

                onSaveClicked = CreateTrigger();
                TriggerRegisterFrameEvent(onSaveClicked, but_SaveWorld, FRAMEEVENT_CONTROL_CLICK);
                TriggerAddAction(onSaveClicked, @OnSave);

                but_QuitWorld = CreateFrameByType("GLUETEXTBUTTON", "PauseMenuButton", gameUI, "ScriptDialogButton", 2);
                SetFrameRelativePoint(but_QuitWorld, FRAMEPOINT_LEFT, gameUI, FRAMEPOINT_LEFT, 0.025, 0.00);
                SetFrameText(but_QuitWorld, "Quit World");
                SetFrameSize(but_QuitWorld, .1, .03);
                ShowFrame(but_QuitWorld, true);
                SetFrameEnabled(but_QuitWorld, Multiplayer::isHost);

                onQuitClicked = CreateTrigger();
                TriggerRegisterFrameEvent(onQuitClicked, but_QuitWorld, FRAMEEVENT_CONTROL_CLICK);
                TriggerAddAction(onQuitClicked, @OnQuit);

                bck_Settings = CreateFrameByType( "BACKDROP", "SettingsBG", gameUI, "", 0 );
                SetFrameBackdropTexture( bck_Settings, 1, "UI\\widgets\\BattleNet\\bnet-tooltip-background.blp", true, true, "UI\\widgets\\BattleNet\\bnet-tooltip-border.blp", BORDER_FLAG_ALL, false );
                SetFrameHeight( bck_Settings, .04 );
                SetFrameBorderSize( bck_Settings, 1, .0125 );
                SetFrameBackgroundSize( bck_Settings, 1, .128 );
                SetFrameBackgroundInsets( bck_Settings, 1, .005, .005, .005, .005 );
                SetFrameRelativePoint(bck_Settings, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_TOPLEFT, 0.2, -0.1);
                SetFrameSize(bck_Settings, 0.5, 0.4);

                txt_RenderDistance = CreateFrameByType("TEXT", "SettingsText", bck_Settings, "", 0);
                SetFrameText(txt_RenderDistance, "Render Distance: 4 (Default = 4)");
                SetFrameRelativePoint(txt_RenderDistance, FRAMEPOINT_TOPLEFT, bck_Settings, FRAMEPOINT_TOPLEFT, 0.01, -0.01);

                sld_RenderDistance = CreateFrame("EscMenuSliderTemplate", bck_Settings, 0, 0);
                ClearFrameAllPoints(sld_RenderDistance);
                SetFrameRelativePoint(sld_RenderDistance, FRAMEPOINT_TOPLEFT, bck_Settings, FRAMEPOINT_TOPLEFT, 0.01, -0.02);
                SetFrameSize(sld_RenderDistance, 0.48, 0.015);
                SetFrameMinMaxValues(sld_RenderDistance, 2, 6);
                SetFrameValue(sld_RenderDistance, 4);

                txt_GenSpeed = CreateFrameByType("TEXT", "SettingsText", bck_Settings, "", 1);
                SetFrameText(txt_GenSpeed, "Generation Speed: 1 (Default = 1)");
                SetFrameRelativePoint(txt_GenSpeed, FRAMEPOINT_TOPLEFT, bck_Settings, FRAMEPOINT_TOPLEFT, 0.01, -0.04);

                sld_GenSpeed = CreateFrame("EscMenuSliderTemplate", bck_Settings, 0, 1);
                ClearFrameAllPoints(sld_GenSpeed);
                SetFrameRelativePoint(sld_GenSpeed, FRAMEPOINT_TOPLEFT, bck_Settings, FRAMEPOINT_TOPLEFT, 0.01, -0.05);
                SetFrameSize(sld_GenSpeed, 0.48, 0.015);
                SetFrameMinMaxValues(sld_GenSpeed, 10, 400);
                SetFrameValue(sld_GenSpeed, 100);

                onSettingsSliderValueChanged = CreateTrigger();
                TriggerRegisterFrameEvent(onSettingsSliderValueChanged, sld_RenderDistance, FRAMEEVENT_SLIDER_VALUE_CHANGED);
                TriggerRegisterFrameEvent(onSettingsSliderValueChanged, sld_GenSpeed, FRAMEEVENT_SLIDER_VALUE_CHANGED);
                TriggerAddAction(onSettingsSliderValueChanged, @OnSettingsSlider);

                Hide();
            }

            void Show() {
                ShowFrame(but_Resume, true);
                ShowFrame(but_SaveWorld, true);
                ShowFrame(but_QuitWorld, true);
                ShowFrame(bck_Settings, true);
                shown = true;
            }

            void Hide() {
                SetFrameFocus(but_Resume, false);
                SetFrameFocus(but_QuitWorld, false);
                SetFrameFocus(but_SaveWorld, false);
                ShowFrame(but_Resume, false);
                ShowFrame(but_QuitWorld, false);
                ShowFrame(but_SaveWorld, false);
                ShowFrame(bck_Settings, false);
                shown = false;
            }
        }
    }
}