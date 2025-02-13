namespace GUI {
    namespace DebugInfo {
        framehandle txt_debug = nil;
        framehandle txt_debug_shadow = nil;
        bool shown = false;
        
        void Create() {
            framehandle gameUI = GetOriginFrame( ORIGIN_FRAME_GAME_UI, 0 );

            txt_debug_shadow = CreateFrameByType("TEXT", "DebugText", gameUI, "", 1);
            SetFrameText(txt_debug_shadow, "DebugInfo");
            SetFrameTextColour(txt_debug_shadow, 0xFF000000);
            SetFrameRelativePoint(txt_debug_shadow, FRAMEPOINT_TOPRIGHT, gameUI, FRAMEPOINT_TOPRIGHT, -0.00425f, -0.00525f);
            ShowFrame(txt_debug_shadow, false);

            txt_debug = CreateFrameByType("TEXT", "DebugText", gameUI, "", 0);
            SetFrameText(txt_debug, "DebugInfo");
            SetFrameRelativePoint(txt_debug, FRAMEPOINT_TOPRIGHT, gameUI, FRAMEPOINT_TOPRIGHT, -0.005f, -0.005f);
            ShowFrame(txt_debug, false);

        }

        void SetText(string text) {
            SetFrameText(txt_debug, text);
            SetFrameText(txt_debug_shadow, text);
        }

        void Switch() {
            if(shown) {
                shown = false;
            } else {
                shown = true;
            }
            ShowFrame(txt_debug, shown);
            ShowFrame(txt_debug_shadow, shown);
        }
    }
}