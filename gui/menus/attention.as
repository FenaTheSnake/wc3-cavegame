namespace GUI {
    namespace Menus {

        // Attention is a short bottom message that is shown up to say something important.
        // ex. "waiting for host" "loading world" "saving world"
        namespace Attention {
            framehandle bck_backdrop;
            framehandle txt_label;

            array<int> attentions;
            array<string> texts;

            void Init() {
                LoadTOCFile("war3mapImported\\so.toc");

                framehandle gameUI = GetOriginFrame( ORIGIN_FRAME_GAME_UI, 0 );

                bck_backdrop = CreateFrameByType( "BACKDROP", "MyTestBackDrop", gameUI, "", 0 );
                SetFrameBackdropTexture( bck_backdrop, 1, "UI\\widgets\\BattleNet\\bnet-tooltip-background.blp", true, true, "UI\\widgets\\BattleNet\\bnet-tooltip-border.blp", BORDER_FLAG_ALL, false );
                SetFrameHeight( bck_backdrop, .04 );
                SetFrameBorderSize( bck_backdrop, 1, .0125 );
                SetFrameBackgroundSize( bck_backdrop, 1, .128 );
                SetFrameBackgroundInsets( bck_backdrop, 1, .005, .005, .005, .005 );
                SetFrameRelativePoint(bck_backdrop, FRAMEPOINT_CENTER, gameUI, FRAMEPOINT_BOTTOM, 0.0, 0.1);
                SetFrameSize(bck_backdrop, 0.2, 0.04);

                txt_label = CreateFrameByType("TEXT", "MyTextFrame2", bck_backdrop, "", 1);
                SetFrameText(txt_label, "Waiting for host to select world.");
                SetFrameRelativePoint(txt_label, FRAMEPOINT_CENTER, bck_backdrop, FRAMEPOINT_CENTER, 0.0, 0.0);

                Hide();
            }

            void Show() {
                ShowFrame(bck_backdrop, true);
                ShowFrame(txt_label, true);
            }

            void Hide() {
                SetFrameFocus(bck_backdrop, false);
                SetFrameFocus(txt_label, false);

                ShowFrame(bck_backdrop, false);
                ShowFrame(txt_label, false);
            }

            void AddAttention(int id, string text) {
                attentions.insertLast(id);
                texts.insertLast(text);
                SetFrameText(txt_label, text);
                Show();
            }
            void RemoveAttention(int id) {
                int i = attentions.find(id);
                if(i >= 0) {
                    attentions.removeAt(i);
                    texts.removeAt(i);
                } else return;
                if(attentions.length() == 0) Hide();
                else SetFrameText(txt_label, texts[texts.length() - 1]);
            }
            void UpdateAttention(int id, string text) {
                int i = attentions.find(id);
                if(i < 0) {
                    return;
                }
                texts[i] = text;
                if(i == texts.length() - 1) SetFrameText(txt_label, text);
            }
        }

    }
}