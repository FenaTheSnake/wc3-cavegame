#include "menus\\worldcreation.as"
#include "menus\\attention.as"
#include "menus\\pausemenu.as"
#include "hotbar.as"
#include "creativeinventory.as"
#include "debuginfo.as"

namespace GUI {
    bool initialized;

    effect blockSelectionEffect;

    bool cursorHidden = false;
    framehandle cursor = nil;
    Vector2 rememberCursorPos = Vector2(0.8/2, 0.6/2);

    void Init() {
        if(initialized) return;

        // CURSOR
        framehandle gameUI = GetOriginFrame( ORIGIN_FRAME_GAME_UI, 0 );
        framehandle texture = CreateFrameByType( "SIMPLETEXTURE", "ItemPurchaseIcon", gameUI, "", 0 );
        SetFrameTexture( texture, "Cursor.blp", 0, false );
        ClearFrameAllPoints( texture );
        SetFrameRelativePoint( texture, FRAMEPOINT_TOPLEFT, gameUI, FRAMEPOINT_CENTER, -0.005f*0.6f, 0.005f*0.6f );
        SetFrameSize( texture, .01 * 0.6f, .01 * 0.8f );
        SetFrameBlendMode( texture, 0, BLEND_MODE_BLEND );
        ShowFrame( texture, true );



        // BLOCK SELECTION EFFECT
        blockSelectionEffect = AddSpecialEffect("blockSelection.mdx", -9999, -9999);

        initialized = true;

        Hotbar::Init();
        CreativeInventory::Init();
    }

    void SetBlockSelectionPosition(World::BlockPos &in blockPos, Vector3 direction) {
        if(blockPos.chunk == null) return;

        Vector3 pos = Vector3(blockPos.x * BLOCK_SIZE, blockPos.y * BLOCK_SIZE, blockPos.z * BLOCK_SIZE);
        pos += Vector3(blockPos.chunk.position.x*CHUNK_SIZE*BLOCK_SIZE, blockPos.chunk.position.y*CHUNK_SIZE*BLOCK_SIZE, blockPos.chunk.position.z*CHUNK_SIZE*BLOCK_SIZE);
        pos = World::AbsolutePositionToWC3Position(pos, true);
        pos = Vector3(pos.x + BLOCK_SIZE / 2, pos.y + BLOCK_SIZE / 2, pos.z + BLOCK_SIZE / 2);

        pos += direction * (BLOCK_SIZE * 0.5F);

        SetSpecialEffectOrientation(blockSelectionEffect, (direction.x != 0) ? 90.0f : 0.0f, 0.0f, (direction.z != 0) ? 90.0f : 0.0f);

        SetSpecialEffectPositionWithZ(blockSelectionEffect, pos.x, pos.y, pos.z);
    }
    void HideBlockSelection() {
        SetSpecialEffectPositionWithZ(blockSelectionEffect, -9999, -9999, -9999);
    }

    void HookCursor() {
        if(cursor == nil) cursor = GetOriginFrame(ORIGIN_FRAME_CURSOR_FRAME, 0);
        rememberCursorPos = Vector2(GetMouseScreenRelativeX(), GetMouseScreenRelativeY());
        SetMouseScreenRelativePosition(FPP::SCREEN_CENTER.x, FPP::SCREEN_CENTER.y);
        Main::player.IgnoreMouseFor(5);   // because fuck me i guess
        SetFrameAlpha(cursor, 0);
        cursorHidden = true;
    }
    void UnhookCursor() {
        if(cursor == nil) cursor = GetOriginFrame(ORIGIN_FRAME_CURSOR_FRAME, 0);
        SetFrameAlpha(cursor, 255);
        SetMouseScreenRelativePosition(rememberCursorPos.x, 0.6 - rememberCursorPos.y);
        cursorHidden = false;
    }

    void OnESC() {
        if(GetTriggerPlayer() != GetLocalPlayer()) return;
        if(Main::isInGame) {
            if(CreativeInventory::shown) {
                CreativeInventory::Hide();
                HookCursor();
                return;
            }

            if(Menus::PauseMenu::shown) {
                Menus::PauseMenu::Hide();
                HookCursor();
            }
            else {
                Menus::PauseMenu::Show();
                UnhookCursor();
            }
        }
    }

    void OnDigitsPressed() {
        if(GetTriggerPlayer() != GetLocalPlayer()) return;

        if(!Menus::PauseMenu::shown) {
            if(CreativeInventory::shown && CreativeInventory::frameMouseOn != nil) CreativeInventory::OnDigitsPressed();
            else Hotbar::OnDigitsPressed();
        }
    }

    void OnInventoryButtonPressed() {
        if(GetTriggerPlayer() != GetLocalPlayer()) return;
        if(Menus::PauseMenu::shown) return;

        if(!CreativeInventory::shown) {
            CreativeInventory::Show();
            UnhookCursor();
        } else {
            CreativeInventory::Hide();
            HookCursor();
        }
    }
}