#include "blizzard.as"
#include "constants.as"
#include "logger.as"
#include "memory\\memory.as"
#include "world\\world.as"
#include "collision\\collision.as"
#include "fpp\\firstpersonplayer.as"
#include "save\\worldsave.as"
#include "save\\global.as"
#include "mptest.as"
#include "gui\\gui.as"
#include "commands\\commands.as"

namespace Main {

    // configurable ingame
    int renderDistance = 4;
    int renderDistance_z = 3;
    float genSpeed = 1.0f;

    // dynamically changed based on fps
    int toGenerateBlocks = MAX_GENERATED_BLOCKS_AT_ONCE;
    int toBuildBlocks = MAX_BUILT_BLOCKS_AT_ONCE;

    FPP::FirstPersonPlayer player;
    World::WorldInstance overworld;
    Save::WorldSave@ overworldSave;
    bool isInGame = false;  // game is started

    trigger trig_chatCommand = nil;
    trigger trig_jump = nil;
    funcdef void OnJumpPressed();
    trigger trig_shift = nil;
    trigger trig_ctrl = nil;
    trigger trig_esc = nil;
    trigger trig_playerleft = nil;


    timer timer_playerUpdate = nil;
    timer timer_worldUpdate = nil;
    timer timer_guiUpdate = nil;
    timer timer_mpUpdate = nil;
    timer timer_cleanup = nil;
    
    void Update() {
        player.Update();
    }

    void LongUpdate() {
        overworld.ProcessRequestedToBuildChunks();
        overworld.UnloadUnrelevantChunksIfNecessary();

        toGenerateBlocks = (MAX_GENERATED_BLOCKS_AT_ONCE - (50 - (GetFPS() - 14)) * (MAX_GENERATED_BLOCKS_AT_ONCE / 50)) * genSpeed;
        toBuildBlocks = (MAX_BUILT_BLOCKS_AT_ONCE - (50 - (GetFPS() - 14)) * (MAX_BUILT_BLOCKS_AT_ONCE / 50)) * genSpeed;
        World::Generator::ProcessGeneratingChunks();
        World::Builder::ProcessBuildingChunks();
        Multiplayer::Update();

        if(GUI::DebugInfo::shown) {
            string dbg = "FPS: " + GetFPS() + "\n";
            dbg += "Chunks Generating / Building: " + World::Generator::chunksBeingGenerated.length() + " / " + World::Builder::chunksBeingBuilt.length() + "\n";
            dbg += "Chunk Pool Used / Free / Capacity: " + Memory::chunkPool.usedChunks.length() + " / " + Memory::chunkPool.freeChunks.length() + " / " + Memory::chunkPool.currentCapacity + "\n";
            dbg += "Scheduled Blocks " + overworld.scheduledBlocks.length() + "\n";
            dbg += "Player Position: " + player.absolute_position + "; Chunk: " + World::AbsolutePositionToChunkPos(player.absolute_position) + "\n"; 
            dbg += "Looking At: " + player.lookingAt + " (" + World::BlockID2Name(player.lookingAtBlockID) + ")\n";
            GUI::DebugInfo::SetText(dbg);
        }
    }

    void GUIUpdate() {
        player.UpdateBlockSelection();
    }

    void PeersSyncUpdate() {
        Multiplayer::SyncAllPeersPositions();
    }

    void Cleanup() {
        overworld.CleanScheduledBlocks();
    }

    void HandleChatCommand() {
        string cmd = GetEventPlayerChatString();
        if(cmd.substr(0, 1) != "/") return;

        Commands::ExecuteCommand(cmd.substr(1, -1), GetTriggerPlayer());
    }

    void HideWarcraftInterface() {
        HideOriginFrames(true);
        EditBlackBorders(0, 0);
    }


    void StartGame(Save::WorldSave@ save) {
        if(isInGame) return;
        isInGame = true;

        Memory::Init();
        GUI::Init();
        GUI::HookCursor();

        @overworldSave = @save;
        @overworld.worldSave = @save;

        player.Init(@overworld, Vector3(-512, 512, 1024));

        if(timer_playerUpdate == nil) {
            timer_playerUpdate = CreateTimer();
            timer_worldUpdate = CreateTimer();
            timer_guiUpdate = CreateTimer();
            timer_mpUpdate = CreateTimer();
            timer_cleanup = CreateTimer();
            TimerStart(timer_playerUpdate, TIME_PLAYER_UPDATE, true, @Update);
            TimerStart(timer_worldUpdate, TIME_WORLD_UPDATE, true, @LongUpdate);
            TimerStart(timer_guiUpdate, TIME_GUI_UPDATE, true, @GUIUpdate);
            TimerStart(timer_mpUpdate, TIME_MP_UPDATE, true, @PeersSyncUpdate);
            TimerStart(timer_cleanup, TIME_CLEANUP, true, @Cleanup);
        }


        if(trig_chatCommand == nil) {
            trig_chatCommand = CreateTrigger();
            trig_jump = CreateTrigger();
            trig_esc = CreateTrigger();
            
            for(int i = 0; i < Multiplayer::players.length(); i++) { 
                TriggerRegisterPlayerChatEvent(trig_chatCommand, Multiplayer::players[i], "/", false);
                TriggerRegisterPlayerKeyEvent(trig_jump, Multiplayer::players[i], OSKEY_SPACE, 0, true);
                TriggerRegisterPlayerKeyEvent(trig_esc, Multiplayer::players[i], OSKEY_ESCAPE, 0, true);
            }
            TriggerAddAction(trig_chatCommand, @HandleChatCommand);
            TriggerAddAction(trig_jump, @OnJumpPressed(player.OnJumpPressed));
            TriggerAddAction(trig_esc, @GUI::OnESC);
        }
    }

    void EndTheGame() {
        if(!isInGame) return;
        isInGame = false;
        overworldSave.Close();

        overworld.Unload();
        overworld = World::WorldInstance();

        World::Generator::chunksBeingGenerated.removeRange(0, World::Generator::chunksBeingGenerated.length());
        World::Generator::chunksBeingGenerated.resize(0);
        World::Builder::chunksBeingBuilt.removeRange(0, World::Builder::chunksBeingBuilt.length());
        World::Builder::chunksBeingBuilt.resize(0);

        DestroyTimer(timer_playerUpdate);
        DestroyTimer(timer_worldUpdate);
        DestroyTimer(timer_guiUpdate);
        DestroyTimer(timer_mpUpdate);
        DestroyTimer(timer_cleanup);
        timer_playerUpdate = nil;

        DestroyTrigger(trig_chatCommand);
        DestroyTrigger(trig_jump);
        DestroyTrigger(trig_esc);
        trig_chatCommand = nil;

        GUI::UnhookCursor();
        if(Multiplayer::isHost) GUI::Menus::WorldCreation::Show();
        else GUI::Menus::Attention::AddAttention(ATTENTION_WAITING_FOR_HOST, ATTENTION_WAITING_FOR_HOST_TEXT);
    }

    void fa() {
        __debug("fa");
    }


    void PostInit() {
        Multiplayer::Init();
        Commands::Init();

        HideWarcraftInterface();
        SetWidescreenState(true);

        GUI::Menus::Attention::Init();
        GUI::Menus::WorldCreation::Init();
        GUI::Menus::PauseMenu::Init();
        GUI::DebugInfo::Create();

        if(Multiplayer::isHost) GUI::Menus::WorldCreation::Show();
        else GUI::Menus::Attention::AddAttention(ATTENTION_WAITING_FOR_HOST, ATTENTION_WAITING_FOR_HOST_TEXT);
    }

    void OnPlayerLeft() {
        DisplayTextToPlayer(GetLocalPlayer(), 0, 0, GetPlayerName(GetTriggerPlayer()) + " has left the game.");
        if(GetTriggerPlayer() == GetHostPlayer()) {
            overworld.Save();
            EndGame(false);
        }
    }

    void Init() {
        SetSkyModel("war3mapImported\\skyLight.mdx");

        FogEnable(false);
        FogMaskEnable(false);

        SetCameraField(CAMERA_FIELD_ZOFFSET, 0.0f, 0.0f);
        SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 0.0f, 0.0f);
        SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 0.0f, 0.0f);
        SetCameraField(CAMERA_FIELD_FIELD_OF_VIEW, 100.0f, 0.0f);
        SetCameraField(CAMERA_FIELD_FARZ, 8000.0f, 0.0f);

        SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12);

        TimerStart(CreateTimer(), 0.1f, false, @PostInit);

        trig_playerleft = CreateTrigger();
        for(int i = 0; i < 12; i++){
            TriggerRegisterPlayerEvent(trig_playerleft, Player(i), EVENT_PLAYER_LEAVE);
        }
        TriggerAddAction(trig_playerleft, @OnPlayerLeft);
    }

    void Config() {
        
    }
}