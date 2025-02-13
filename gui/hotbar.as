namespace GUI {
    namespace Hotbar {
        framehandle hotbar;
        framehandle bck_hotbar;
        array<framehandle> mdl_blocks;
        
        array<World::BlockID> blocks(HOTBAR_CAPACITY);

        int selectedBlock;

        void Init() {
            framehandle gameUI = GetOriginFrame( ORIGIN_FRAME_GAME_UI, 0 );

            hotbar = CreateFrameByType("SPRITE", "Hotbar", gameUI, "", 0);
            ClearFrameAllPoints(hotbar);
            SetFrameRelativePoint(hotbar, FRAMEPOINT_BOTTOM, gameUI, FRAMEPOINT_BOTTOM, 0.0, 0.0);
            SetFrameSize(hotbar, .01, .01);

            bck_hotbar = CreateFrameByType( "BACKDROP", "HotbarBG", hotbar, "", 0 );
            SetFrameBackdropTexture( bck_hotbar, 1, "UI\\widgets\\BattleNet\\bnet-tooltip-background.blp", true, true, "UI\\widgets\\BattleNet\\bnet-tooltip-border.blp", BORDER_FLAG_ALL, false );
            SetFrameHeight( bck_hotbar, .04 );
            SetFrameBorderSize( bck_hotbar, 1, .0125 );
            SetFrameBackgroundSize( bck_hotbar, 1, .128 );
            SetFrameBackgroundInsets( bck_hotbar, 1, .005, .005, .005, .005 );
            SetFrameRelativePoint(bck_hotbar, FRAMEPOINT_BOTTOM, hotbar, FRAMEPOINT_BOTTOM, 0.005, 0.025);
            SetFrameSize(bck_hotbar, 0.31, 0.04);

            for(int i = 0; i < HOTBAR_CAPACITY; i++) {
                framehandle mdl_block = CreateFrameByType("SPRITE", "BlockModel", hotbar, "", i);
                ClearFrameAllPoints(mdl_block);
                SetFrameRelativePoint(mdl_block, FRAMEPOINT_BOTTOM, hotbar, FRAMEPOINT_BOTTOM, -0.135 + 0.03*i, 0.04);
                SetFrameSize(mdl_block, .01, .01);
                SetFrameLayerFlag(mdl_block, LAYER_STYLE_IGNORE_TRACK_EVENTS, true);
                ShowFrame(mdl_block, true);

                SetFrameSpriteModel(mdl_block, "block.mdx");
                SetFrameSpriteScale(mdl_block, 0.0001);
                SetFrameSpriteOrientation(mdl_block, -30., 45., 45.);

                mdl_blocks.insertLast(mdl_block);
                blocks[i] = World::BlockID(i+1);
            }

            UpdateHotbarBlocksGraphics();
            SetSelectedBlock(1);

        }

        void UpdateHotbarBlocksGraphics() {
            for(int i = 0; i < HOTBAR_CAPACITY; i++) {
                SetFrameSpriteMaterialTexture(mdl_blocks[i], World::BlockID2Texture(blocks[i]), 0, 0);
            }
        }

        void SetSelectedBlock(int newValue) {
            SetFrameRelativePoint(mdl_blocks[selectedBlock], FRAMEPOINT_BOTTOM, hotbar, FRAMEPOINT_BOTTOM, -0.135 + 0.03*selectedBlock, 0.04);
            selectedBlock = newValue;
            SetFrameRelativePoint(mdl_blocks[selectedBlock], FRAMEPOINT_BOTTOM, hotbar, FRAMEPOINT_BOTTOM, -0.135 + 0.03*selectedBlock, 0.0475);
        }

        void OnDigitsPressed() {
            int n = GetHandleId(GetTriggerPlayerKey()) - 49;
            n = (n < 0) ? (HOTBAR_CAPACITY-1) : ((n >= HOTBAR_CAPACITY) ? 0 : n);

            SetSelectedBlock(n);
        }

        World::BlockID GetSelectedBlock() {
            return blocks[selectedBlock];
        }

        void Show() {
            ShowFrame(hotbar, true);
        }
        void Hide() {
            ShowFrame(hotbar, false);
        }
    }
}