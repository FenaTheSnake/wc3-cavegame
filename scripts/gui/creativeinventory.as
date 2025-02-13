namespace GUI {
    namespace CreativeInventory {
        framehandle inventory;
        framehandle bck_inventory;
        array<framehandle> mdl_blocks;
        array<framehandle> simplebuttons;

        framehandle txt_hint;
        
        array<World::BlockID> blocks(CINV_SIZE);

        int selectedBlock;
        
        bool shown;

        trigger trig_MouseEnter;
        trigger trig_MouseLeft;
        trigger trig_MouseClick;
        framehandle frameMouseOn = nil;

        void OnMouseEnter() {
            if(frameMouseOn != nil) {
                //SetFrameScale(frameMouseOn, 0.0001);
            }

            for(int i = 0; i < simplebuttons.length(); i++) {
                if(simplebuttons[i] == GetTriggerFrame()) {
                    frameMouseOn = GetTriggerFrame();
                    //SetFrameRelativePoint(mdl_blocks[i], FRAMEPOINT_CENTER, GetTriggerFrame(), FRAMEPOINT_CENTER, 0.002, 0.0);
                }
            }

            //SetFrameScale(frameMouseOn, 0.000115);
        }

        void OnMouseLeft() {
            if(frameMouseOn != nil) {
                //SetFrameRelativePoint(frameMouseOn, FRAMEPOINT_CENTER, GetFrameParent(frameMouseOn), FRAMEPOINT_CENTER, 0.002, 0.0);
                //SetFrameScale(frameMouseOn, 0.0001);
                frameMouseOn = nil;
            }
        }

        void OnMouseClick() {
            for(int i = 0; i < simplebuttons.length(); i++) {
                if(simplebuttons[i] == GetTriggerFrame()) {
                    Hotbar::blocks[Hotbar::selectedBlock] = blocks[i];
                    Hotbar::UpdateHotbarBlocksGraphics();
                }
            }
            Hide();
            GUI::HookCursor();
        }

        void Init() {
            framehandle gameUI = GetOriginFrame( ORIGIN_FRAME_GAME_UI, 0 );

            inventory = CreateFrameByType("SPRITE", "inventory", gameUI, "", 0);
            ClearFrameAllPoints(inventory);
            SetFrameRelativePoint(inventory, FRAMEPOINT_BOTTOM, gameUI, FRAMEPOINT_BOTTOM, 0.0, 0.0);
            SetFrameSize(inventory, .01, .01);

            txt_hint = CreateFrameByType("TEXT", "InventoryHint", inventory, "", 0);
            SetFrameText(txt_hint, "|cffffcc00Click on block to move it to active HOTBAR slot.\nPress (0-9) while hovering on block\nto move it to corresponding HOTBAR slot.|r");
            SetFrameRelativePoint(txt_hint, FRAMEPOINT_LEFT, gameUI, FRAMEPOINT_LEFT, 0.01, 0.0);

            bck_inventory = CreateFrameByType( "BACKDROP", "InventoryBG", inventory, "", 0 );
            SetFrameBackdropTexture( bck_inventory, 1, "UI\\widgets\\BattleNet\\bnet-tooltip-background.blp", true, true, "UI\\widgets\\BattleNet\\bnet-tooltip-border.blp", BORDER_FLAG_ALL, false );
            SetFrameHeight( bck_inventory, .04 );
            SetFrameBorderSize( bck_inventory, 1, .0125 );
            SetFrameBackgroundSize( bck_inventory, 1, .128 );
            SetFrameBackgroundInsets( bck_inventory, 1, .005, .005, .005, .005 );
            SetFrameRelativePoint(bck_inventory, FRAMEPOINT_TOP, inventory, FRAMEPOINT_BOTTOM, 0.0, 0.5);
            SetFrameSize(bck_inventory, 0.31, 0.35);

            trig_MouseEnter = CreateTrigger();
            trig_MouseLeft = CreateTrigger();
            trig_MouseClick = CreateTrigger();
            TriggerAddAction(trig_MouseEnter, @OnMouseEnter);
            TriggerAddAction(trig_MouseLeft, @OnMouseLeft);
            TriggerAddAction(trig_MouseClick, @OnMouseClick);

            for(int i = 0; i < CINV_SIZE; i++) {
                // framehandle bck_sex = CreateFrameByType( "BACKDROP", "InventoryBlockBG", bck_inventory, "", i );
                // SetFrameBackdropTexture( bck_sex, 1, "UI\\widgets\\BattleNet\\bnet-tooltip-background.blp", true, true, "UI\\widgets\\BattleNet\\bnet-tooltip-border.blp", BORDER_FLAG_ALL, false );
                // SetFrameHeight( bck_sex, .04 );
                // SetFrameBorderSize( bck_sex, 1, .0125 );
                // SetFrameBackgroundSize( bck_sex, 1, .128 );
                // SetFrameBackgroundInsets( bck_sex, 1, .005, .005, .005, .005 );
                // SetFrameRelativePoint(bck_sex, FRAMEPOINT_TOPLEFT, bck_inventory, FRAMEPOINT_TOPLEFT, 0.005 + 0.03*i, -0.01);
                // SetFrameSize(bck_sex, 0.03, 0.03);

                int row = MathRealFloor(i / CINV_ROW_SIZE);
                int column = i % CINV_ROW_SIZE;

                framehandle but_sex = CreateFrameByType("SIMPLEBUTTON", "", bck_inventory, "", 0);
                ClearFrameAllPoints(but_sex);
                SetFrameSize(but_sex, 0.03, 0.03);
                SetFrameRelativePoint(but_sex, FRAMEPOINT_TOPLEFT, bck_inventory, FRAMEPOINT_TOPLEFT, 0.005 + 0.03*column, -0.01 - 0.03 * row);

                framehandle mdl_block = CreateFrameByType("SPRITE", "InvBlockModel", but_sex, "", i);
                ClearFrameAllPoints(mdl_block);
                SetFrameRelativePoint(mdl_block, FRAMEPOINT_CENTER, but_sex, FRAMEPOINT_CENTER, 0.002, 0.0);
                SetFrameSize(mdl_block, .01, .01);
                SetFrameLayerFlag(mdl_block, LAYER_STYLE_IGNORE_TRACK_EVENTS, true);
                ShowFrame(mdl_block, true);

                SetFrameSpriteModel(mdl_block, "block.mdx");
                SetFrameSpriteScale(mdl_block, 0.0001);
                SetFrameSpriteOrientation(mdl_block, -30., 45., 45.);

                mdl_blocks.insertLast(mdl_block);
                simplebuttons.insertLast(but_sex);
                blocks[i] = World::BlockID(i+1);

                TriggerRegisterFrameEvent(trig_MouseEnter, but_sex, FRAMEEVENT_MOUSE_ENTER);
                TriggerRegisterFrameEvent(trig_MouseLeft, but_sex, FRAMEEVENT_MOUSE_LEAVE);
                TriggerRegisterFrameEvent(trig_MouseClick, but_sex, FRAMEEVENT_CONTROL_CLICK);
            }

            UpdateInventoryBlocksGraphics();
            Hide();
        }

        void UpdateInventoryBlocksGraphics() {
            for(int i = 0; i < CINV_SIZE; i++) {
                SetFrameSpriteMaterialTexture(mdl_blocks[i], World::BlockID2Texture(blocks[i]), 0, 0);
            }
        }

        void OnDigitsPressed() {
            int n = GetHandleId(GetTriggerPlayerKey()) - 49;
            n = (n < 0) ? (HOTBAR_CAPACITY-1) : ((n >= HOTBAR_CAPACITY) ? 0 : n);

            for(int i = 0; i < simplebuttons.length(); i++) {
                if(simplebuttons[i] == frameMouseOn) {
                    Hotbar::blocks[n] = blocks[i];
                    Hotbar::UpdateHotbarBlocksGraphics();
                }
            }
        }

        World::BlockID GetSelectedBlock() {
            return blocks[selectedBlock];
        }

        void Show() {
            ShowFrame(inventory, true);
            for(int i = 0; i < CINV_SIZE; i++) {
                ShowFrame(mdl_blocks[i], true);
                ShowFrame(simplebuttons[i], true);
            }
            shown = true;
        }
        void Hide() {
            ShowFrame(inventory, false);
            for(int i = 0; i < CINV_SIZE; i++) {
                ShowFrame(mdl_blocks[i], false);
                ShowFrame(simplebuttons[i], false);
            }
            shown = false;
        }
    }
}