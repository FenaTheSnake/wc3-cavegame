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
    int renderDistance = 4;
    int renderDistance_z = 3;

    // dynamically changed based on fps
    int toGenerateBlocks = MAX_GENERATED_BLOCKS_AT_ONCE;
    int toBuildBlocks = MAX_BUILT_BLOCKS_AT_ONCE;

    FPP::FirstPersonPlayer player;
    World::WorldInstance overworld;
    Save::WorldSave@ overworldSave;

    trigger trig_chatCommand = nil;
    trigger trig_jump = nil;
    funcdef void OnJumpPressed();
    trigger trig_shift = nil;
    trigger trig_ctrl = nil;


    void Update() {
        player.Update();
    }

    void LongUpdate() {
        overworld.ProcessRequestedToBuildChunks();
        overworld.UnloadUnrelevantChunksIfNecessary();

        toGenerateBlocks = MAX_GENERATED_BLOCKS_AT_ONCE - (50 - (GetFPS() - 14)) * (MAX_GENERATED_BLOCKS_AT_ONCE / 50);
        toBuildBlocks = MAX_BUILT_BLOCKS_AT_ONCE - (50 - (GetFPS() - 14)) * (MAX_BUILT_BLOCKS_AT_ONCE / 50);
        World::Generator::ProcessGeneratingChunks();
        World::Builder::ProcessBuildingChunks();
        Multiplayer::Update();

        if(GUI::DebugInfo::shown) {
            string dbg = "FPS: " + GetFPS() + "\n";
            dbg += "Chunks Generating / Building: " + World::Generator::chunksBeingGenerated.length() + " / " + World::Builder::chunksBeingBuilt.length() + "\n";
            dbg += "Chunk Pool Used / Free / Capacity: " + Memory::chunkPool.usedChunks.length() + " / " + Memory::chunkPool.freeChunks.length() + " / " + Memory::chunkPool.currentCapacity + "\n";
            dbg += "Scheduled Blocks " + overworld.scheduledBlocks.length() + "\n";
            dbg += "Player Position: " + player.absolute_position + "; Chunk: " + World::AbsolutePositionToChunkPos(player.absolute_position) + "\n"; 
            dbg += "Looking At: " + player.lookingAt + "\n";
            GUI::DebugInfo::SetText(dbg);
        }
    }

    void GUIUpdate() {
        player.UpdateBlockSelection();
    }


    // these functions (badly) tries to fix some awful chunks graphics problems that I can't resolve because i AM LOSIng my sanity :)
    void FuckMe() {
        if(overworld.repositionBuiltChunksWhenYouAreReadyPleaseNoPressureJustDoItButPreferablyDoItSoonerOk) {
            overworld.UpdateBuiltChunksPositions();
            overworld.repositionBuiltChunksWhenYouAreReadyPleaseNoPressureJustDoItButPreferablyDoItSoonerOk = false;
        }
    }
    void FuckMe2() {
        overworld.repositionBuiltChunksWhenYouAreReadyPleaseNoPressureJustDoItButPreferablyDoItSoonerOk = true;
    }

    void PeersSyncUpdate() {
        Multiplayer::SyncAllPeersPositions();
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
        Memory::Init();
        GUI::Init();

        @overworldSave = @save;
        @overworld.worldSave = @save;

        player.Init(@overworld, Vector3(-512, 512, 1024));

        TimerStart(CreateTimer(), TIME_PLAYER_UPDATE, true, @Update);
        TimerStart(CreateTimer(), TIME_WORLD_UPDATE, true, @LongUpdate);
        TimerStart(CreateTimer(), TIME_GUI_UPDATE, true, @GUIUpdate);
        TimerStart(CreateTimer(), TIME_MP_UPDATE, true, @PeersSyncUpdate);
        TimerStart(CreateTimer(), 0.50f, true, @FuckMe);
        TimerStart(CreateTimer(), 2.00f, true, @FuckMe2);

        if(trig_chatCommand == nil) {
            trig_chatCommand = CreateTrigger();
            trig_jump = CreateTrigger();
            for(int i = 0; i < Multiplayer::players.length(); i++) { 
                TriggerRegisterPlayerChatEvent(trig_chatCommand, Multiplayer::players[i], "/", false);
                TriggerAddAction(trig_chatCommand, @HandleChatCommand);
                TriggerRegisterPlayerKeyEvent(trig_jump, Multiplayer::players[i], OSKEY_SPACE, 0, true);
                TriggerAddAction(trig_jump, @OnJumpPressed(player.OnJumpPressed));
            }
        }
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
        GUI::DebugInfo::Create();

        if(Multiplayer::isHost) GUI::Menus::WorldCreation::Show();
        else GUI::Menus::Attention::AddAttention(ATTENTION_WAITING_FOR_HOST, ATTENTION_WAITING_FOR_HOST_TEXT);
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
    }

    void Config() {
        
    }
}